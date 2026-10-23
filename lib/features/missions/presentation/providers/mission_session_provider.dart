import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/speech_recognizer_service.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../../../l10n/app_strings.dart';
import '../../../auth/domain/user_profile.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../review/presentation/providers/review_provider.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../../data/mock_conversation_repository.dart';
import '../../domain/chat_message.dart';
import '../../domain/conversation_repository.dart';
import '../../domain/conversation_state.dart';
import '../../domain/debrief_ref.dart';
import '../../domain/session_config.dart';
import '../../domain/suggestion.dart';

/// Provider for the [ConversationRepository].
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final translationRepo = ref.watch(translationRepositoryProvider);
  return MockConversationRepository(translationRepository: translationRepo);
});

/// Provider managing the simulated offline state of the mission session.
final missionSessionIsOfflineProvider = StateProvider<bool>((ref) => false);

/// StateNotifier driving a role-play mission conversation session.
///
/// Follows AGENTS.md §2.3 (autoDispose notifier), §4.7 (survives rotation/window resize),
/// and §6 (user isolation).
class MissionSessionNotifier extends StateNotifier<ConversationState> {
  MissionSessionNotifier({
    required this.config,
    required this.repository,
    required this.user,
    required this.settings,
    required this.ttsService,
    required this.speechRecognizer,
  }) : super(const ConversationState()) {
    _initSession();
  }

  final SessionConfig config;
  final ConversationRepository repository;
  final UserProfile? user;
  final AppSettings settings;
  final TextToSpeechService ttsService;
  final SpeechRecognizerService speechRecognizer;

  String? _sessionId;
  int _turnIndex = 0;
  bool _isDisposed = false;
  Timer? _timeoutTimer;

  String? get sessionId => _sessionId;

  Future<void> _initSession() async {
    state = state.copyWith(status: ConversationStatus.starting);
    _armTimeout();

    try {
      final start = await repository.startSession(config);
      _cancelTimeout();
      if (_isDisposed) return;

      _sessionId = start.sessionId;
      final suggestions = config.support.id == 'guided'
          ? start.suggestions.take(3).toList()
          : const <Suggestion>[];

      state = state.copyWith(
        status: ConversationStatus.userTurn,
        characterName: start.characterName,
        characterRole: start.characterRole,
        emoji: start.emoji,
        goals: start.goals,
        suggestions: suggestions,
        messages: [start.initialMessage],
        clearErrorMessage: true,
      );

      _handleAutoplay(start.initialMessage);
    } on MissionLanguageUnavailableException {
      _cancelTimeout();
      if (!_isDisposed) {
        state = state.copyWith(status: ConversationStatus.unavailable);
      }
    } on MissionSessionRateLimitException {
      _cancelTimeout();
      if (!_isDisposed) {
        state = state.copyWith(
          status: ConversationStatus.failed,
          errorMessage: AppStrings.sessionRateLimitNotice,
        );
      }
    } catch (_) {
      _cancelTimeout();
      if (!_isDisposed) {
        state = state.copyWith(
          status: ConversationStatus.failed,
          errorMessage: AppStrings.sessionGenericErrorNotice,
        );
      }
    }
  }

  void _armTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (!_isDisposed && state.status == ConversationStatus.starting) {
        state = state.copyWith(
          status: ConversationStatus.failed,
          errorMessage: AppStrings.sessionTimeoutNotice,
        );
      }
    });
  }

  void _cancelTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  void updateDraftText(String text) {
    if (_isDisposed) return;
    state = state.copyWith(draftText: text);
  }

  Future<void> sendUserMessage([String? overrideText]) async {
    final text = (overrideText ?? state.draftText).trim();
    if (text.isEmpty || _sessionId == null) return;

    final sid = _sessionId!;
    _turnIndex++;
    final clientTurnId = 'turn_${sid}_${_turnIndex}_${DateTime.now().millisecondsSinceEpoch}';

    final userMsg = ChatMessage(
      id: 'msg_user_${sid}_$_turnIndex',
      clientTurnId: clientTurnId,
      author: MessageAuthor.user,
      targetText: text,
      deliveryState: MessageDeliveryState.sending,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      status: ConversationStatus.sending,
      messages: [...state.messages, userMsg],
      draftText: '',
      pendingClientTurnId: clientTurnId,
      suggestions: const [],
      clearErrorMessage: true,
    );

    await _executeTurn(sid: sid, clientTurnId: clientTurnId, userMsg: userMsg, text: text);
  }

  Future<void> retryFailedMessage(ChatMessage failedMessage) async {
    if (_sessionId == null || failedMessage.clientTurnId == null) return;
    final sid = _sessionId!;
    final clientTurnId = failedMessage.clientTurnId!;

    final updated = state.messages.map((m) {
      if (m.id == failedMessage.id) {
        return m.copyWith(deliveryState: MessageDeliveryState.sending);
      }
      return m;
    }).toList();

    state = state.copyWith(
      status: ConversationStatus.sending,
      messages: updated,
      clearErrorMessage: true,
      pendingClientTurnId: clientTurnId,
    );

    await _executeTurn(
      sid: sid,
      clientTurnId: clientTurnId,
      userMsg: failedMessage,
      text: failedMessage.targetText,
    );
  }

  Future<void> _executeTurn({
    required String sid,
    required String clientTurnId,
    required ChatMessage userMsg,
    required String text,
  }) async {
    try {
      final turnResult = await repository.sendTurn(
        sessionId: sid,
        clientTurnId: clientTurnId,
        userText: text,
        config: config,
      );

      if (_isDisposed) return;

      // Update user message to sent
      final updatedMessages = state.messages.map((m) {
        if (m.id == userMsg.id) {
          return m.copyWith(
            deliveryState: MessageDeliveryState.sent,
            correction: turnResult.correction,
          );
        }
        return m;
      }).toList();

      // Update goal states
      final updatedGoals = state.goals.map((g) {
        if (turnResult.completedGoalIds.contains(g.id)) {
          return g.copyWith(isDone: true);
        }
        return g;
      }).toList();

      final suggestions = config.support.id == 'guided'
          ? turnResult.suggestions.take(3).toList()
          : const <Suggestion>[];

      final nextStatus = turnResult.isFinished
          ? ConversationStatus.finished
          : ConversationStatus.userTurn;

      state = state.copyWith(
        status: nextStatus,
        messages: [...updatedMessages, turnResult.characterMessage],
        goals: updatedGoals,
        suggestions: suggestions,
        isFinished: turnResult.isFinished,
        pendingClientTurnId: null,
      );

      _handleAutoplay(turnResult.characterMessage);
    } catch (_) {
      if (_isDisposed) return;

      final updatedMessages = state.messages.map((m) {
        if (m.id == userMsg.id) {
          return m.copyWith(deliveryState: MessageDeliveryState.failed);
        }
        return m;
      }).toList();

      state = state.copyWith(
        status: ConversationStatus.failed,
        messages: updatedMessages,
        errorMessage: AppStrings.sessionGenericErrorNotice,
      );
    }
  }

  void deleteFailedMessage(String messageId) {
    if (_isDisposed) return;
    final message = state.messages.firstWhere((m) => m.id == messageId);
    final filtered = state.messages.where((m) => m.id != messageId).toList();
    state = state.copyWith(
      messages: filtered,
      draftText: message.targetText,
      status: ConversationStatus.userTurn,
      clearErrorMessage: true,
    );
  }

  Future<void> playMessageAudio(ChatMessage message) async {
    final locale = message.audioLocale ??
        (config.targetLanguageCode == 'fr' ? 'fr-FR' : 'es-ES');
    await ttsService.speak(message.targetText, locale: locale);
  }

  void _handleAutoplay(ChatMessage message) {
    if (!settings.autoplay) return;
    if (speechRecognizer.isListening) return;
    if (state.latestSpokenMessageId == message.id) return;

    state = state.copyWith(latestSpokenMessageId: message.id);
    playMessageAudio(message);
  }

  Future<String> translateForSayInMyLanguage(String text) async {
    return repository.translateForUser(
      text: text,
      targetLanguageCode: config.targetLanguageCode,
      explanationLanguageCode: config.explanationLanguageCode,
    );
  }

  Future<void> reportMessage({required String messageId, required String reason}) async {
    if (_sessionId == null) return;
    await repository.reportMessage(
      sessionId: _sessionId!,
      messageId: messageId,
      reason: reason,
    );
  }

  Future<DebriefRef> finishSession() async {
    final sid = _sessionId ?? 'session_default';
    state = state.copyWith(status: ConversationStatus.finishing);
    final debrief = await repository.finishSession(sid);
    if (!_isDisposed) {
      state = state.copyWith(
        status: ConversationStatus.finished,
        debriefRef: debrief,
      );
    }
    return debrief;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelTimeout();
    ttsService.stop();
    super.dispose();
  }
}

/// Riverpod family provider for [MissionSessionNotifier].
final missionSessionNotifierProvider = StateNotifierProvider.autoDispose
    .family<MissionSessionNotifier, ConversationState, SessionConfig>((
  ref,
  config,
) {
  final repository = ref.watch(conversationRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final settings = ref.watch(appSettingsProvider);
  final ttsService = ref.watch(textToSpeechServiceProvider);
  final speechRecognizer = ref.watch(speechRecognizerServiceProvider);

  return MissionSessionNotifier(
    config: config,
    repository: repository,
    user: user,
    settings: settings,
    ttsService: ttsService,
    speechRecognizer: speechRecognizer,
  );
});

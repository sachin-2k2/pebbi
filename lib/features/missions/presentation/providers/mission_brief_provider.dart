import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/speech_recognizer_service.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../../../l10n/app_strings.dart';
import '../../../auth/domain/user_profile.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../lesson/domain/speaking_safety_rules.dart';
import '../../../onboarding/data/mock_learnable_language_repository.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../../domain/correction_style.dart';
import '../../domain/mission_brief.dart';
import '../../domain/mission_mode.dart';
import '../../domain/mission_repository.dart';
import '../../domain/mission_support.dart';
import '../../domain/start_mission_gate.dart';
import 'missions_provider.dart';

/// State representation for the Mission Brief screen.
class MissionBriefState {
  const MissionBriefState({
    required this.brief,
    required this.selectedMode,
    required this.selectedSupport,
    required this.targetLanguageName,
    this.isStarting = false,
    this.isPlayingAudio = false,
    this.isVoiceAvailable = true,
    this.voiceDisabledReason,
    this.transientMessage,
  });

  final MissionBrief brief;
  final MissionMode selectedMode;
  final MissionSupport selectedSupport;
  final String targetLanguageName;
  final bool isStarting;
  final bool isPlayingAudio;
  final bool isVoiceAvailable;
  final String? voiceDisabledReason;
  final String? transientMessage;

  bool get isSuggestedRepliesOn => selectedSupport.hasSuggestedReplies;

  MissionBriefState copyWith({
    MissionBrief? brief,
    MissionMode? selectedMode,
    MissionSupport? selectedSupport,
    String? targetLanguageName,
    bool? isStarting,
    bool? isPlayingAudio,
    bool? isVoiceAvailable,
    String? voiceDisabledReason,
    String? transientMessage,
    bool clearTransientMessage = false,
  }) {
    return MissionBriefState(
      brief: brief ?? this.brief,
      selectedMode: selectedMode ?? this.selectedMode,
      selectedSupport: selectedSupport ?? this.selectedSupport,
      targetLanguageName: targetLanguageName ?? this.targetLanguageName,
      isStarting: isStarting ?? this.isStarting,
      isPlayingAudio: isPlayingAudio ?? this.isPlayingAudio,
      isVoiceAvailable: isVoiceAvailable ?? this.isVoiceAvailable,
      voiceDisabledReason: voiceDisabledReason ?? this.voiceDisabledReason,
      transientMessage: clearTransientMessage
          ? null
          : (transientMessage ?? this.transientMessage),
    );
  }
}

/// Simulated or reactive offline mode provider for the Mission Brief.
final missionBriefIsOfflineProvider = StateProvider<bool>((ref) => false);

/// State notifier managing the active Mission Brief lifecycle.
///
/// Follows AGENTS.md §2.3 & §6: Watches [currentUserProvider] to isolate
/// user-scoped defaults and completion state.
class MissionBriefNotifier
    extends StateNotifier<AsyncValue<MissionBriefState>> {
  MissionBriefNotifier({
    required this.missionId,
    required this.repository,
    required this.user,
    required this.settings,
    required this.ttsService,
    required this.speechRecognizer,
    required this.isOffline,
  }) : super(const AsyncValue.loading()) {
    _load();
  }

  final String missionId;
  final MissionRepository repository;
  final UserProfile? user;
  final AppSettings settings;
  final TextToSpeechService ttsService;
  final SpeechRecognizerService speechRecognizer;
  final bool isOffline;

  bool _isDisposed = false;
  Timer? _interGoalTimer;
  Completer<void>? _delayCompleter;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final userId = user?.userId ?? 'guest_default';
      final targetLang = user?.targetLanguageCode ?? 'es';
      final explanationLang = user?.explanationLanguageCode ?? 'en';

      final brief = await repository.loadBrief(
        missionId: missionId,
        userId: userId,
        targetLanguageCode: targetLang,
        explanationLanguageCode: explanationLang,
      );

      if (brief == null) {
        if (!_isDisposed) {
          state = AsyncValue.error('Mission not found', StackTrace.current);
        }
        return;
      }

      // Load user defaults
      final defaultMode = await repository.getDefaultMode(userId: userId);
      final defaultSupport = await repository.getDefaultSupport(userId: userId);

      // Check voice availability
      final (isVoiceAvailable, disabledReason) = _evaluateVoiceAvailability(
        brief,
      );

      // Graceful fallback if saved default mode was Voice but is now unavailable
      MissionMode effectiveMode = defaultMode;
      String? transientNotice;
      if (defaultMode == MissionMode.voice && !isVoiceAvailable) {
        effectiveMode = MissionMode.chat;
        transientNotice = disabledReason;
      }

      // Resolve target language name dynamically
      final languageName = _resolveLanguageName(brief.languageCode);

      if (!_isDisposed) {
        state = AsyncValue.data(
          MissionBriefState(
            brief: brief,
            selectedMode: effectiveMode,
            selectedSupport: defaultSupport,
            targetLanguageName: languageName,
            isVoiceAvailable: isVoiceAvailable,
            voiceDisabledReason: disabledReason,
            transientMessage: transientNotice,
          ),
        );
      }
    } catch (e, st) {
      if (!_isDisposed) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  (bool, String?) _evaluateVoiceAvailability(MissionBrief brief) {
    if (!settings.speakingPracticeEnabled) {
      return (false, AppStrings.voiceDisabledSpeakingOff);
    }
    if (!SpeakingSafetyRules.shouldAllowSpeaking(user?.ageBand)) {
      return (false, AppStrings.voiceDisabledAge);
    }
    if (!speechRecognizer.isAvailable &&
        speechRecognizer.hasPermission == false) {
      // Checked dynamically when starting, but if capability unavailable:
    }
    if (!brief.supportsVoice) {
      return (false, AppStrings.voiceDisabledScene);
    }
    return (true, null);
  }

  String _resolveLanguageName(String code) {
    const repo = MockLearnableLanguageRepository();
    final lang = repo
        .getLearnableLanguages()
        .where((l) => l.code == code)
        .firstOrNull;
    if (lang != null) return lang.englishName;

    switch (code) {
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'ja':
        return 'Japanese';
      case 'ar':
        return 'Arabic';
      default:
        return 'Spanish';
    }
  }

  Future<void> selectMode(MissionMode mode) async {
    final current = state.valueOrNull;
    if (current == null) return;

    if (mode == MissionMode.voice && !current.isVoiceAvailable) {
      state = AsyncValue.data(
        current.copyWith(
          transientMessage:
              current.voiceDisabledReason ??
              AppStrings.voiceDisabledSpeakingOff,
        ),
      );
      return;
    }

    state = AsyncValue.data(
      current.copyWith(selectedMode: mode, clearTransientMessage: true),
    );

    final userId = user?.userId ?? 'guest_default';
    await repository.saveDefaultMode(userId: userId, mode: mode);
  }

  Future<void> selectSupport(MissionSupport support) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(selectedSupport: support));

    final userId = user?.userId ?? 'guest_default';
    await repository.saveDefaultSupport(userId: userId, support: support);
  }

  Future<void> toggleHearGoals() async {
    final current = state.valueOrNull;
    if (current == null) return;

    if (current.isPlayingAudio) {
      await stopAudio();
      return;
    }

    state = AsyncValue.data(current.copyWith(isPlayingAudio: true));

    final explanationCode = user?.explanationLanguageCode ?? 'en';
    final locale = explanationCode == 'es' ? 'es-ES' : 'en-US';

    for (final goal in current.brief.goals) {
      if (_isDisposed) break;
      final latest = state.valueOrNull;
      if (latest == null || !latest.isPlayingAudio) break;

      await ttsService.speak(goal.text, locale: locale);
      if (_isDisposed || state.valueOrNull?.isPlayingAudio != true) break;

      final completer = Completer<void>();
      _delayCompleter = completer;
      _interGoalTimer = Timer(const Duration(milliseconds: 600), () {
        if (!completer.isCompleted) completer.complete();
      });
      await completer.future;
      _interGoalTimer = null;
      _delayCompleter = null;
    }

    if (!_isDisposed && state.valueOrNull?.isPlayingAudio == true) {
      state = AsyncValue.data(
        state.valueOrNull!.copyWith(isPlayingAudio: false),
      );
    }
  }

  Future<void> stopAudio() async {
    final current = state.valueOrNull;
    if (!_isDisposed && current != null && current.isPlayingAudio) {
      state = AsyncValue.data(current.copyWith(isPlayingAudio: false));
    }

    _interGoalTimer?.cancel();
    _interGoalTimer = null;
    if (_delayCompleter != null && !_delayCompleter!.isCompleted) {
      _delayCompleter!.complete();
    }
    _delayCompleter = null;

    await ttsService.stop();
  }

  Future<StartMissionOutcome> startMission({
    required bool isOfflineCheck,
    required CorrectionStyle correctionStyle,
    required bool captionsOn,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      return StartMissionOutcome.needsInternet();
    }

    await stopAudio();
    state = AsyncValue.data(current.copyWith(isStarting: true));

    bool hasMicPermission = true;
    if (current.selectedMode == MissionMode.voice) {
      final initialized = await speechRecognizer.initialize();
      hasMicPermission = initialized && speechRecognizer.hasPermission;
    }

    final explanationLang = user?.explanationLanguageCode ?? 'en';

    final outcome = StartMissionGate.evaluate(
      isOffline: isOfflineCheck,
      user: user,
      brief: current.brief,
      selectedMode: current.selectedMode,
      selectedSupport: current.selectedSupport,
      correctionStyle: correctionStyle,
      captionsOn: captionsOn,
      hasMicPermission: hasMicPermission,
      explanationLanguageCode: explanationLang,
    );

    if (!_isDisposed) {
      if (outcome.type ==
          StartMissionOutcomeType.voicePermissionDeniedFallbackToChat) {
        state = AsyncValue.data(
          current.copyWith(
            isStarting: false,
            selectedMode: MissionMode.chat,
            transientMessage: AppStrings.voicePermissionFallback,
          ),
        );
      } else {
        state = AsyncValue.data(current.copyWith(isStarting: false));
      }
    }

    return outcome;
  }

  void clearTransientMessage() {
    final current = state.valueOrNull;
    if (current != null && current.transientMessage != null) {
      state = AsyncValue.data(current.copyWith(clearTransientMessage: true));
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _interGoalTimer?.cancel();
    _interGoalTimer = null;
    if (_delayCompleter != null && !_delayCompleter!.isCompleted) {
      _delayCompleter!.complete();
    }
    _delayCompleter = null;
    ttsService.stop();
    super.dispose();
  }
}

/// Riverpod family provider for [MissionBriefNotifier].
final missionBriefNotifierProvider = StateNotifierProvider.autoDispose
    .family<MissionBriefNotifier, AsyncValue<MissionBriefState>, String>((
      ref,
      missionId,
    ) {
      final repository = ref.watch(missionRepositoryProvider);
      final user = ref.watch(currentUserProvider);
      final settings = ref.watch(appSettingsProvider);
      final ttsService = ref.watch(textToSpeechServiceProvider);
      final speechRecognizer = ref.watch(speechRecognizerServiceProvider);
      final isOffline = ref.watch(missionBriefIsOfflineProvider);

      return MissionBriefNotifier(
        missionId: missionId,
        repository: repository,
        user: user,
        settings: settings,
        ttsService: ttsService,
        speechRecognizer: speechRecognizer,
        isOffline: isOffline,
      );
    });

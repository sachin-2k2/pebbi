import 'dart:async';
import '../../review/domain/translation_repository.dart';
import '../domain/chat_message.dart';
import '../domain/conversation_repository.dart';
import '../domain/debrief_ref.dart';
import '../domain/session_config.dart';
import '../domain/session_goal.dart';
import '../domain/session_start.dart';
import '../domain/session_turn_result.dart';
import '../domain/suggestion.dart';

/// In-memory scripted mock implementation of [ConversationRepository].
///
/// Follows AGENTS.md §1 & §2.2:
/// - Pure simulation without external network or AI provider calls
/// - Supports screenshot scenario (French café dialogue with Lucía)
/// - Idempotent by [clientTurnId]
/// - Configurable latency and failure modes for testing
class MockConversationRepository implements ConversationRepository {
  MockConversationRepository({
    this.simulatedLatency = const Duration(milliseconds: 50),
    this.simulateTimeout = false,
    this.simulateNetworkError = false,
    this.simulateRateLimit = false,
    this.translationRepository,
  });

  Duration simulatedLatency;
  bool simulateTimeout;
  bool simulateNetworkError;
  bool simulateRateLimit;
  final TranslationRepository? translationRepository;

  final Map<String, int> _sessionTurnCounters = {};
  final Map<String, Set<String>> _sessionCompletedGoals = {};
  final Map<String, TurnResult> _idempotentCache = {};
  final List<({String sessionId, String messageId, String reason})> reportedMessages = [];

  void reset() {
    _sessionTurnCounters.clear();
    _sessionCompletedGoals.clear();
    _idempotentCache.clear();
    reportedMessages.clear();
  }

  @override
  Future<SessionStart> startSession(SessionConfig config) async {
    await Future<void>.delayed(simulatedLatency);

    if (simulateTimeout) {
      throw const MissionSessionTimeoutException();
    }
    if (simulateNetworkError) {
      throw Exception('Connection failed');
    }
    if (simulateRateLimit) {
      throw const MissionSessionRateLimitException();
    }

    final targetLang = config.targetLanguageCode;
    if (targetLang != 'fr' && targetLang != 'es') {
      throw MissionLanguageUnavailableException(targetLang);
    }

    final sessionId = 'sess_${config.missionId}_${DateTime.now().millisecondsSinceEpoch}';
    _sessionTurnCounters[sessionId] = 0;
    _sessionCompletedGoals[sessionId] = <String>{};

    if (targetLang == 'es') {
      // TODO(question: content team must supply and review all scenes in all languages)
      return SessionStart(
        sessionId: sessionId,
        characterName: 'Lucía',
        characterRole: 'barista',
        emoji: '☕',
        goals: const [
          SessionGoal(id: 'g1', text: 'Pedir una bebida'),
          SessionGoal(id: 'g2', text: 'Preguntar el precio'),
          SessionGoal(id: 'g3', text: 'Pagar y dar las gracias'),
        ],
        initialMessage: ChatMessage(
          id: 'msg_init_$sessionId',
          author: MessageAuthor.character,
          targetText: '¡Hola! Bienvenido. ¿Qué te gustaría tomar?',
          translationText: 'Hello! Welcome. What would you like to have?',
          audioLocale: 'es-ES',
          timestamp: DateTime.now(),
        ),
        suggestions: const [
          Suggestion(id: 's1', text: 'Un café, por favor.', translation: 'A coffee, please.'),
          Suggestion(id: 's2', text: 'Un chocolate caliente, por favor.', translation: 'A hot chocolate, please.'),
          Suggestion(id: 's3', text: 'Un té, por favor.', translation: 'A tea, please.'),
        ],
      );
    }

    // Default French Café dialogue (exact match to screenshot)
    return SessionStart(
      sessionId: sessionId,
      characterName: 'Lucía',
      characterRole: 'barista',
      emoji: '☕',
      goals: const [
        SessionGoal(id: 'g1', text: 'Order a drink'),
        SessionGoal(id: 'g2', text: 'Ask the price'),
        SessionGoal(id: 'g3', text: 'Pay and say thank you'),
      ],
      initialMessage: ChatMessage(
        id: 'msg_init_$sessionId',
        author: MessageAuthor.character,
        targetText: 'Bonjour ! Bienvenue. Que voulez-vous boire ?',
        translationText: 'Hello! Welcome. What would you like to drink?',
        audioLocale: 'fr-FR',
        timestamp: DateTime.now(),
      ),
      suggestions: const [
        Suggestion(id: 's1', text: "Un café, s'il vous plaît.", translation: 'A coffee, please.'),
        Suggestion(id: 's2', text: "Un chocolat chaud, s'il vous plaît.", translation: 'A hot chocolate, please.'),
        Suggestion(id: 's3', text: "Un thé, s'il vous plaît.", translation: 'A tea, please.'),
      ],
    );
  }

  @override
  Future<TurnResult> sendTurn({
    required String sessionId,
    required String clientTurnId,
    required String userText,
    required SessionConfig config,
  }) async {
    await Future<void>.delayed(simulatedLatency);

    // Idempotency: Return cached response if this clientTurnId has already executed
    if (_idempotentCache.containsKey(clientTurnId)) {
      return _idempotentCache[clientTurnId]!;
    }

    if (simulateTimeout) {
      throw const MissionSessionTimeoutException();
    }
    if (simulateNetworkError) {
      throw Exception('Connection failed');
    }
    if (simulateRateLimit) {
      throw const MissionSessionRateLimitException();
    }

    final turnIndex = _sessionTurnCounters[sessionId] ?? 0;
    final nextTurn = turnIndex + 1;
    _sessionTurnCounters[sessionId] = nextTurn;
    final completed = _sessionCompletedGoals.putIfAbsent(sessionId, () => <String>{});

    final targetLang = config.targetLanguageCode;
    final isFrench = targetLang == 'fr';
    final locale = isFrench ? 'fr-FR' : 'es-ES';

    TurnResult result;
    if (nextTurn == 1) {
      // Goal 1 achieved
      completed.add('g1');
      result = TurnResult(
        completedGoalIds: ['g1'],
        characterMessage: ChatMessage(
          id: 'msg_char_${sessionId}_$nextTurn',
          author: MessageAuthor.character,
          targetText: isFrench
              ? 'Très bien, un café ! Avec du lait ou sans lait ?'
              : '¡Muy bien, un café! ¿Con leche o sin leche?',
          translationText: 'Great, a coffee! With milk or without milk?',
          audioLocale: locale,
          timestamp: DateTime.now(),
        ),
        suggestions: isFrench
            ? const [
                Suggestion(id: 's2_1', text: "Avec du lait, s'il vous plaît.", translation: 'With milk, please.'),
                Suggestion(id: 's2_2', text: "Sans lait, s'il vous plaît.", translation: 'Without milk, please.'),
                Suggestion(id: 's2_3', text: 'Combien ça coûte ?', translation: 'How much does it cost?'),
              ]
            : const [
                Suggestion(id: 's2_1', text: 'Con leche, por favor.', translation: 'With milk, please.'),
                Suggestion(id: 's2_2', text: 'Sin leche, por favor.', translation: 'Without milk, please.'),
                Suggestion(id: 's2_3', text: '¿Cuánto cuesta?', translation: 'How much does it cost?'),
              ],
      );
    } else if (nextTurn == 2) {
      // Goal 2 achieved
      completed.add('g2');
      result = TurnResult(
        completedGoalIds: ['g1', 'g2'],
        correction: config.correctionStyle.id == 'live'
            ? (isFrench ? "Un café au lait, s'il vous plaît" : 'Un café con leche, por favor')
            : null,
        characterMessage: ChatMessage(
          id: 'msg_char_${sessionId}_$nextTurn',
          author: MessageAuthor.character,
          targetText: isFrench
              ? 'Ça fera trois euros, s\'il vous plaît.'
              : 'Serán tres euros, por favor.',
          translationText: 'That will be three euros, please.',
          audioLocale: locale,
          timestamp: DateTime.now(),
        ),
        suggestions: isFrench
            ? const [
                Suggestion(id: 's3_1', text: 'Voici trois euros, merci !', translation: 'Here is three euros, thank you!'),
                Suggestion(id: 's3_2', text: 'Puis-je payer par carte ?', translation: 'Can I pay by card?'),
                Suggestion(id: 's3_3', text: 'Merci beaucoup !', translation: 'Thank you very much!'),
              ]
            : const [
                Suggestion(id: 's3_1', text: 'Aquí tiene tres euros, ¡gracias!', translation: 'Here is three euros, thank you!'),
                Suggestion(id: 's3_2', text: '¿Puedo pagar con tarjeta?', translation: 'Can I pay by card?'),
                Suggestion(id: 's3_3', text: '¡Muchas gracias!', translation: 'Thank you very much!'),
              ],
      );
    } else {
      // Goal 3 achieved & Session finished
      completed.add('g3');
      result = TurnResult(
        completedGoalIds: ['g1', 'g2', 'g3'],
        isFinished: true,
        characterMessage: ChatMessage(
          id: 'msg_char_${sessionId}_$nextTurn',
          author: MessageAuthor.character,
          targetText: isFrench
              ? 'Merci beaucoup ! Bonne journée et à bientôt !'
              : '¡Muchas gracias! ¡Que tengas un buen día y hasta pronto!',
          translationText: 'Thank you very much! Have a nice day and see you soon!',
          audioLocale: locale,
          timestamp: DateTime.now(),
        ),
        suggestions: const [],
      );
    }

    _idempotentCache[clientTurnId] = result;
    return result;
  }

  @override
  Future<String> translateForUser({
    required String text,
    required String targetLanguageCode,
    required String explanationLanguageCode,
  }) async {
    await Future<void>.delayed(simulatedLatency);
    if (translationRepository != null) {
      return translationRepository!.translate(
        query: text,
        targetLanguageCode: targetLanguageCode,
        explanationLanguageCode: explanationLanguageCode,
      );
    }

    // Default heuristic for mock tests
    if (targetLanguageCode == 'fr') {
      if (text.toLowerCase().contains('coffee')) {
        return "Un café, s'il vous plaît.";
      }
      return 'Je voudrais commander, merci.';
    }
    return 'Quisiera pedir un café, por favor.';
  }

  @override
  Future<void> reportMessage({
    required String sessionId,
    required String messageId,
    required String reason,
  }) async {
    await Future<void>.delayed(simulatedLatency);
    reportedMessages.add((sessionId: sessionId, messageId: messageId, reason: reason));
  }

  @override
  Future<DebriefRef> finishSession(String sessionId) async {
    await Future<void>.delayed(simulatedLatency);
    final turns = _sessionTurnCounters[sessionId] ?? 1;
    final completed = _sessionCompletedGoals[sessionId] ?? <String>{};

    return DebriefRef(
      sessionId: sessionId,
      missionId: 'order_coffee',
      turnsCount: turns,
      completedGoalIds: completed.toList(),
      totalGoals: 3,
    );
  }
}

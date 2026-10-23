import 'debrief_ref.dart';
import 'session_config.dart';
import 'session_start.dart';
import 'session_turn_result.dart';

/// Thrown when a role-play mission has not yet been localized for the requested target language.
class MissionLanguageUnavailableException implements Exception {
  const MissionLanguageUnavailableException(this.languageCode);
  final String languageCode;

  @override
  String toString() => 'Mission not available in language: $languageCode';
}

/// Thrown when the user exceeds their daily role-play session quota.
class MissionSessionRateLimitException implements Exception {
  const MissionSessionRateLimitException();
}

/// Thrown when the role-play backend service times out during turn synthesis.
class MissionSessionTimeoutException implements Exception {
  const MissionSessionTimeoutException();
}

/// Repository interface governing role-play conversation sessions.
///
/// Follows AGENTS.md §1 & §2.2: Pure Dart contract; server logic is provided by backend team.
abstract interface class ConversationRepository {
  /// Initializes a role-play conversation session.
  Future<SessionStart> startSession(SessionConfig config);

  /// Submits a user message turn and returns the character reply and progress.
  ///
  /// [clientTurnId] provides client-side idempotency so retries never duplicate turns.
  Future<TurnResult> sendTurn({
    required String sessionId,
    required String clientTurnId,
    required String userText,
    required SessionConfig config,
  });

  /// Translates user-provided text for "Say it in my language".
  Future<String> translateForUser({
    required String text,
    required String targetLanguageCode,
    required String explanationLanguageCode,
  });

  /// Submits an in-session message moderation report.
  Future<void> reportMessage({
    required String sessionId,
    required String messageId,
    required String reason,
  });

  /// Closes the session and prepares the debrief summary.
  Future<DebriefRef> finishSession(String sessionId);
}

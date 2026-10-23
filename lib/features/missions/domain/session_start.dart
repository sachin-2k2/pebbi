import 'chat_message.dart';
import 'session_goal.dart';
import 'suggestion.dart';

/// Payload returned when initializing a role-play mission session.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class SessionStart {
  const SessionStart({
    required this.sessionId,
    required this.initialMessage,
    required this.suggestions,
    required this.goals,
    required this.characterName,
    required this.characterRole,
    required this.emoji,
  });

  final String sessionId;
  final ChatMessage initialMessage;
  final List<Suggestion> suggestions;
  final List<SessionGoal> goals;
  final String characterName;
  final String characterRole;
  final String emoji;
}

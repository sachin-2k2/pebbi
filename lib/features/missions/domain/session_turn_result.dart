import 'chat_message.dart';
import 'suggestion.dart';

/// Result returned from the conversation backend for a completed turn.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class TurnResult {
  const TurnResult({
    required this.characterMessage,
    this.suggestions = const [],
    this.completedGoalIds = const [],
    this.correction,
    this.isFinished = false,
    this.notice,
  });

  final ChatMessage characterMessage;
  final List<Suggestion> suggestions;
  final List<String> completedGoalIds;
  final String? correction;
  final bool isFinished;
  final String? notice;
}

import 'chat_message.dart';
import 'debrief_ref.dart';
import 'session_goal.dart';
import 'suggestion.dart';

/// Status machine states for the active role-play conversation.
enum ConversationStatus {
  starting,
  waitingForCharacter,
  userTurn,
  sending,
  failed,
  finishing,
  finished,
  unavailable,
}

/// Pure Dart state representation for a role-play mission session.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class ConversationState {
  const ConversationState({
    this.status = ConversationStatus.starting,
    this.messages = const [],
    this.goals = const [],
    this.suggestions = const [],
    this.characterName = '',
    this.characterRole = '',
    this.emoji = '☕',
    this.draftText = '',
    this.errorMessage,
    this.pendingClientTurnId,
    this.allGoalsDoneNotified = false,
    this.isFinished = false,
    this.debriefRef,
    this.latestSpokenMessageId,
  });

  final ConversationStatus status;
  final List<ChatMessage> messages;
  final List<SessionGoal> goals;
  final List<Suggestion> suggestions;
  final String characterName;
  final String characterRole;
  final String emoji;
  final String draftText;
  final String? errorMessage;
  final String? pendingClientTurnId;
  final bool allGoalsDoneNotified;
  final bool isFinished;
  final DebriefRef? debriefRef;
  final String? latestSpokenMessageId;

  /// True when the user is permitted to type and send.
  bool get canSend =>
      (status == ConversationStatus.userTurn || status == ConversationStatus.failed) &&
      draftText.trim().isNotEmpty;

  /// True when the user has sent at least one successful message.
  bool get hasUserSpoken =>
      messages.any((m) => m.isFromUser && m.deliveryState == MessageDeliveryState.sent);

  int get completedGoalsCount => goals.where((g) => g.isDone).length;

  bool get areAllGoalsDone => goals.isNotEmpty && goals.every((g) => g.isDone);

  ConversationState copyWith({
    ConversationStatus? status,
    List<ChatMessage>? messages,
    List<SessionGoal>? goals,
    List<Suggestion>? suggestions,
    String? characterName,
    String? characterRole,
    String? emoji,
    String? draftText,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? pendingClientTurnId,
    bool? allGoalsDoneNotified,
    bool? isFinished,
    DebriefRef? debriefRef,
    String? latestSpokenMessageId,
  }) {
    return ConversationState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      goals: goals ?? this.goals,
      suggestions: suggestions ?? this.suggestions,
      characterName: characterName ?? this.characterName,
      characterRole: characterRole ?? this.characterRole,
      emoji: emoji ?? this.emoji,
      draftText: draftText ?? this.draftText,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      pendingClientTurnId: pendingClientTurnId ?? this.pendingClientTurnId,
      allGoalsDoneNotified: allGoalsDoneNotified ?? this.allGoalsDoneNotified,
      isFinished: isFinished ?? this.isFinished,
      debriefRef: debriefRef ?? this.debriefRef,
      latestSpokenMessageId: latestSpokenMessageId ?? this.latestSpokenMessageId,
    );
  }
}

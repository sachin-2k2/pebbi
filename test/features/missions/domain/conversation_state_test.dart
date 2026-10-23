import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/missions/domain/chat_message.dart';
import 'package:peddi/features/missions/domain/conversation_state.dart';
import 'package:peddi/features/missions/domain/debrief_ref.dart';
import 'package:peddi/features/missions/domain/session_goal.dart';
import 'package:peddi/features/missions/domain/suggestion.dart';

void main() {
  group('ConversationState Domain Tests', () {
    test('Initial defaults: starting status, cannot send, empty messages', () {
      const state = ConversationState();
      expect(state.status, ConversationStatus.starting);
      expect(state.canSend, isFalse);
      expect(state.hasUserSpoken, isFalse);
      expect(state.completedGoalsCount, 0);
      expect(state.areAllGoalsDone, isFalse);
    });

    test('canSend requires userTurn or failed status and non-whitespace text', () {
      const emptyState = ConversationState(
        status: ConversationStatus.userTurn,
        draftText: '   ',
      );
      expect(emptyState.canSend, isFalse);

      const readyState = ConversationState(
        status: ConversationStatus.userTurn,
        draftText: 'Bonjour',
      );
      expect(readyState.canSend, isTrue);

      const failedState = ConversationState(
        status: ConversationStatus.failed,
        draftText: 'Bonjour',
      );
      expect(failedState.canSend, isTrue);

      const sendingState = ConversationState(
        status: ConversationStatus.sending,
        draftText: 'Bonjour',
      );
      expect(sendingState.canSend, isFalse);
    });

    test('Goals progress and completion calculation', () {
      const g1 = SessionGoal(id: 'g1', text: 'Order a drink', isDone: true);
      const g2 = SessionGoal(id: 'g2', text: 'Ask price', isDone: false);
      const state = ConversationState(goals: [g1, g2]);

      expect(state.completedGoalsCount, 1);
      expect(state.areAllGoalsDone, isFalse);

      final allDoneState = state.copyWith(
        goals: [g1, g2.copyWith(isDone: true)],
      );
      expect(allDoneState.completedGoalsCount, 2);
      expect(allDoneState.areAllGoalsDone, isTrue);
    });

    test('hasUserSpoken tracks successful user deliveries', () {
      final now = DateTime.now();
      final charMsg = ChatMessage(
        id: 'm1',
        author: MessageAuthor.character,
        targetText: 'Bonjour',
        timestamp: now,
      );
      final userSending = ChatMessage(
        id: 'm2',
        author: MessageAuthor.user,
        targetText: 'Un café',
        deliveryState: MessageDeliveryState.sending,
        timestamp: now,
      );
      final userSent = ChatMessage(
        id: 'm3',
        author: MessageAuthor.user,
        targetText: 'Merci',
        deliveryState: MessageDeliveryState.sent,
        timestamp: now,
      );

      final s1 = ConversationState(messages: [charMsg, userSending]);
      expect(s1.hasUserSpoken, isFalse);

      final s2 = ConversationState(messages: [charMsg, userSent]);
      expect(s2.hasUserSpoken, isTrue);
    });

    test('DebriefRef calculates completion ratio correctly', () {
      const refZero = DebriefRef(
        sessionId: 's1',
        missionId: 'order_coffee',
        turnsCount: 0,
        completedGoalIds: [],
        totalGoals: 0,
      );
      expect(refZero.completionRatio, 0.0);

      const refPartial = DebriefRef(
        sessionId: 's2',
        missionId: 'order_coffee',
        turnsCount: 3,
        completedGoalIds: ['g1', 'g2'],
        totalGoals: 3,
      );
      expect(refPartial.completionRatio, closeTo(0.666, 0.01));

      const refComplete = DebriefRef(
        sessionId: 's3',
        missionId: 'order_coffee',
        turnsCount: 5,
        completedGoalIds: ['g1', 'g2', 'g3'],
        totalGoals: 3,
      );
      expect(refComplete.completionRatio, 1.0);
    });

    test('Suggestion model value equality', () {
      const s1 = Suggestion(id: 's1', text: 'Un thé', translation: 'A tea');
      const s2 = Suggestion(id: 's1', text: 'Un thé', translation: 'A tea');
      const s3 = Suggestion(id: 's2', text: 'Un café', translation: 'A coffee');

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
    });
  });
}

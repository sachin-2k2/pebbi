import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/missions/domain/debrief_ref.dart';
import 'package:peddi/features/missions/presentation/screens/mission_debrief_screen.dart';

void main() {
  Widget buildScreen({DebriefRef? debriefRef}) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        home: MissionDebriefScreen(debriefRef: debriefRef),
      ),
    );
  }

  group('MissionDebriefScreen Tests', () {
    testWidgets('renders celebratory hero, rewards, and goals card', (tester) async {
      const debrief = DebriefRef(
        sessionId: 'session_123',
        missionId: 'order-a-coffee',
        turnsCount: 3,
        completedGoalIds: ['1', '2', '3'],
        totalGoals: 3,
        characterName: 'Lucía',
        completedGoalTexts: ['Order a drink', 'Ask the price', 'Pay and say thank you'],
        starsEarned: 25,
      );

      await tester.pumpWidget(buildScreen(debriefRef: debrief));
      await tester.pumpAndSettle();

      expect(find.text('Mission Complete! 🎉'), findsOneWidget);
      expect(find.text('Great conversation with Lucía'), findsOneWidget);
      expect(find.text('+25'), findsOneWidget);
      expect(find.text('3/3'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Order a drink'), findsOneWidget);
      expect(find.text('Ask the price'), findsOneWidget);
      expect(find.text('Pay and say thank you'), findsOneWidget);
      expect(find.text('Return to Missions'), findsOneWidget);
    });

    testWidgets('renders Free Talk debrief with praise, corrections, and vocab recap', (tester) async {
      const debrief = DebriefRef(
        sessionId: 'freetalk_123',
        missionId: 'freetalk',
        turnsCount: 6,
        completedGoalIds: ['1', '2', '3'],
        totalGoals: 3,
        characterName: 'Pebbi',
        completedGoalTexts: ['Keep the conversation going', 'Ask one question back'],
        starsEarned: 25,
        praise: 'Great job! You maintained a smooth conversation about food.',
        corrections: [
          DebriefCorrection(
            userSaid: 'Yo gusta pizza',
            betterWay: 'Me gusta la pizza',
            explanation: 'In Spanish, we use "me gusta" instead of "yo gusta".',
          ),
        ],
        vocabularyRecap: ['plato favorito', 'ingredientes', 'deliciosa'],
      );

      await tester.pumpWidget(buildScreen(debriefRef: debrief));
      await tester.pumpAndSettle();

      expect(find.text('Mission Complete! 🎉'), findsOneWidget);
      expect(find.text('Great conversation with Pebbi'), findsOneWidget);
      expect(find.text('Great job! You maintained a smooth conversation about food.'), findsOneWidget);
      expect(find.text('BETTER PHRASING'), findsOneWidget);
      expect(find.text('Yo gusta pizza'), findsOneWidget);
      expect(find.text('Me gusta la pizza'), findsOneWidget);
      expect(find.text('In Spanish, we use "me gusta" instead of "yo gusta".'), findsOneWidget);
      expect(find.text('VOCABULARY USED'), findsOneWidget);
      expect(find.text('plato favorito'), findsOneWidget);
      expect(find.text('ingredientes'), findsOneWidget);
      expect(find.text('deliciosa'), findsOneWidget);
    });

    testWidgets('renders gracefully with null debriefRef fallback', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Mission Complete! 🎉'), findsOneWidget);
      expect(find.text('+25'), findsOneWidget);
      expect(find.text('Return to Missions'), findsOneWidget);
    });
  });
}

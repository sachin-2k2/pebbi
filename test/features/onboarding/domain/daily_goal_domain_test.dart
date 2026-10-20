import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/domain/daily_goal_info.dart';
import 'package:peddi/features/onboarding/domain/daily_goal_selection_rules.dart';
import 'package:peddi/features/onboarding/domain/onboarding_state.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('DailyGoalInfo Domain Tests', () {
    test('allGoals contains exactly 4 predefined goals in order', () {
      expect(DailyGoalInfo.allGoals.length, 4);

      expect(DailyGoalInfo.allGoals[0].id, DailyGoalId.casual);
      expect(DailyGoalInfo.allGoals[0].minutes, 5);
      expect(DailyGoalInfo.allGoals[0].emoji, '🌱');
      expect(DailyGoalInfo.allGoals[0].isOpenEnded, isFalse);

      expect(DailyGoalInfo.allGoals[1].id, DailyGoalId.regular);
      expect(DailyGoalInfo.allGoals[1].minutes, 10);
      expect(DailyGoalInfo.allGoals[1].emoji, '🌿');
      expect(DailyGoalInfo.allGoals[1].isOpenEnded, isFalse);

      expect(DailyGoalInfo.allGoals[2].id, DailyGoalId.serious);
      expect(DailyGoalInfo.allGoals[2].minutes, 15);
      expect(DailyGoalInfo.allGoals[2].emoji, '🌲');
      expect(DailyGoalInfo.allGoals[2].isOpenEnded, isFalse);

      expect(DailyGoalInfo.allGoals[3].id, DailyGoalId.intense);
      expect(DailyGoalInfo.allGoals[3].minutes, 20);
      expect(DailyGoalInfo.allGoals[3].emoji, '⛰️');
      expect(DailyGoalInfo.allGoals[3].isOpenEnded, isTrue);
    });

    test('captions format correctly with parameters including 20+ form', () {
      expect(DailyGoalInfo.allGoals[0].caption, '5 min a day');
      expect(DailyGoalInfo.allGoals[1].caption, '10 min a day');
      expect(DailyGoalInfo.allGoals[2].caption, '15 min a day');
      expect(DailyGoalInfo.allGoals[3].caption, '20+ min a day');
    });

    test('settingsChipLabel formats correctly for all tiers', () {
      expect(
        DailyGoalInfo.allGoals[0].settingsChipLabel,
        'Casual · 5 min a day',
      );
      expect(
        DailyGoalInfo.allGoals[1].settingsChipLabel,
        'Regular · 10 min a day',
      );
      expect(
        DailyGoalInfo.allGoals[2].settingsChipLabel,
        'Serious · 15 min a day',
      );
      expect(
        DailyGoalInfo.allGoals[3].settingsChipLabel,
        'Intense · 20+ min a day',
      );
    });

    test('forId and forStringId resolve correctly and fallback to regular', () {
      expect(DailyGoalInfo.forId(DailyGoalId.serious).id, DailyGoalId.serious);
      expect(DailyGoalInfo.forStringId('casual').id, DailyGoalId.casual);
      expect(DailyGoalInfo.forStringId('intense').id, DailyGoalId.intense);
      expect(DailyGoalInfo.forStringId('unknown_id').id, DailyGoalId.regular);
    });
  });

  group('DailyGoalSelectionRules Tests', () {
    test('defaultGoalId is regular', () {
      expect(DailyGoalSelectionRules.defaultGoalId, 'regular');
    });

    test('selecting a different goal updates selection', () {
      final updated = DailyGoalSelectionRules.select(
        currentGoalId: 'regular',
        newGoalId: 'intense',
      );
      expect(updated, 'intense');
    });

    test('selecting the same goal returns identical id without mutation', () {
      final updated = DailyGoalSelectionRules.select(
        currentGoalId: 'regular',
        newGoalId: 'regular',
      );
      expect(updated, 'regular');
    });
  });

  group('OnboardingState Daily Goal Persistence', () {
    test('default selectedGoalId is regular', () {
      const state = OnboardingState();
      expect(state.selectedGoalId, 'regular');
    });

    test('copyWith updates selectedGoalId correctly', () {
      const state = OnboardingState();
      final updated = state.copyWith(selectedGoalId: 'serious');
      expect(updated.selectedGoalId, 'serious');
    });
  });

  group('AppStrings Daily Goal Semantics', () {
    test('dailyGoalCardSemantics produces expected accessibility strings', () {
      final regularSemantics = AppStrings.dailyGoalCardSemantics(
        name: 'Regular',
        minutes: 10,
        index: 2,
        total: 4,
        isSelected: true,
      );
      expect(
        regularSemantics,
        'Regular, 10 minutes a day, option 2 of 4, selected',
      );

      final casualSemantics = AppStrings.dailyGoalCardSemantics(
        name: 'Casual',
        minutes: 5,
        index: 1,
        total: 4,
        isSelected: false,
      );
      expect(casualSemantics, 'Casual, 5 minutes a day, option 1 of 4');

      final intenseSemantics = AppStrings.dailyGoalCardSemantics(
        name: 'Intense',
        minutes: 20,
        index: 4,
        total: 4,
        isSelected: true,
        isOpenEnded: true,
      );
      expect(
        intenseSemantics,
        'Intense, 20 or more minutes a day, option 4 of 4, selected',
      );
    });
  });
}

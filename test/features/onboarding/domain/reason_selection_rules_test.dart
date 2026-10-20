import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/data/mock_learning_reason_repository.dart';
import 'package:peddi/features/onboarding/domain/onboarding_state.dart';
import 'package:peddi/features/onboarding/domain/reason_selection_rules.dart';

void main() {
  group('ReasonSelectionRules Domain Unit Tests', () {
    test('selecting up to 3 reasons succeeds', () {
      var selected = <String>{};

      selected = ReasonSelectionRules.toggle(selected, 'travel');
      expect(selected, equals({'travel'}));

      selected = ReasonSelectionRules.toggle(selected, 'work');
      expect(selected, equals({'travel', 'work'}));

      selected = ReasonSelectionRules.toggle(selected, 'culture');
      expect(selected, equals({'travel', 'work', 'culture'}));
    });

    test('4th selection is rejected and returns unchanged set', () {
      final selected = {'travel', 'work', 'culture'};

      expect(ReasonSelectionRules.canSelect(selected, 'exams'), isFalse);

      final attempted = ReasonSelectionRules.toggle(selected, 'exams');
      expect(attempted, equals({'travel', 'work', 'culture'}));
      expect(attempted.length, equals(3));
    });

    test('tapping an already selected item deselects it', () {
      final selected = {'travel', 'work', 'culture'};

      expect(ReasonSelectionRules.canSelect(selected, 'work'), isTrue);

      final updated = ReasonSelectionRules.toggle(selected, 'work');
      expect(updated, equals({'travel', 'culture'}));
      expect(updated.length, equals(2));
    });

    test('canSelect returns true when set has fewer than 3 items', () {
      expect(ReasonSelectionRules.canSelect({}, 'travel'), isTrue);
      expect(ReasonSelectionRules.canSelect({'travel'}, 'work'), isTrue);
      expect(
        ReasonSelectionRules.canSelect({'travel', 'work'}, 'exams'),
        isTrue,
      );
      expect(
        ReasonSelectionRules.canSelect({'travel', 'work', 'exams'}, 'culture'),
        isFalse,
      );
    });
  });

  group('MockLearningReasonRepository Unit Tests', () {
    const repository = MockLearningReasonRepository();

    test('returns exactly 9 learning reasons with unique non-empty IDs', () {
      final reasons = repository.getReasons();
      expect(reasons.length, equals(9));

      final ids = reasons.map((r) => r.id).toSet();
      expect(ids.length, equals(9));

      for (final reason in reasons) {
        expect(reason.id.isNotEmpty, isTrue);
        expect(reason.label.isNotEmpty, isTrue);
        expect(reason.iconEmoji.isNotEmpty, isTrue);
      }
    });
  });

  group('OnboardingState selectedReasonIds Unit Tests', () {
    test('defaults to empty set and updates immutably', () {
      const state = OnboardingState();
      expect(state.selectedReasonIds, isEmpty);

      final updated = state.copyWith(selectedReasonIds: {'travel', 'work'});
      expect(updated.selectedReasonIds, equals({'travel', 'work'}));
    });
  });
}

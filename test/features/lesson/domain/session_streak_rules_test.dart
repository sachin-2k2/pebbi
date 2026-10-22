import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/lesson/domain/session_streak_rules.dart';

void main() {
  group('SessionStreakRules domain unit tests', () {
    test('streak increments on first-try correct answer', () {
      final s1 = SessionStreakRules.onAnswerChecked(
        currentStreak: 0,
        isCorrect: true,
        isFirstTry: true,
      );
      expect(s1, equals(1));

      final s2 = SessionStreakRules.onAnswerChecked(
        currentStreak: 1,
        isCorrect: true,
        isFirstTry: true,
      );
      expect(s2, equals(2));
    });

    test('streak resets to 0 on wrong answer', () {
      final s = SessionStreakRules.onAnswerChecked(
        currentStreak: 4,
        isCorrect: false,
        isFirstTry: true,
      );
      expect(s, equals(0));
    });

    test('streak resets to 0 when not first try (e.g. redo round)', () {
      final s = SessionStreakRules.onAnswerChecked(
        currentStreak: 2,
        isCorrect: true,
        isFirstTry: false,
      );
      expect(s, equals(0));
    });

    test('streak resets to 0 on explicit skip', () {
      expect(SessionStreakRules.onSkip(), equals(0));
    });

    test('shouldShowStreak evaluates threshold (>= 2)', () {
      expect(SessionStreakRules.shouldShowStreak(0), isFalse);
      expect(SessionStreakRules.shouldShowStreak(1), isFalse);
      expect(SessionStreakRules.shouldShowStreak(2), isTrue);
      expect(SessionStreakRules.shouldShowStreak(3), isTrue);
      expect(SessionStreakRules.shouldShowStreak(5), isTrue);
    });
  });
}

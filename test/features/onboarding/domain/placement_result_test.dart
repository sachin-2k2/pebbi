import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/lesson/domain/exercise.dart';
import 'package:peddi/features/lesson/domain/exercise_result.dart';
import 'package:peddi/features/onboarding/domain/language_level.dart';
import 'package:peddi/features/onboarding/domain/level_info.dart';
import 'package:peddi/features/onboarding/domain/placement_evaluator.dart';
import 'package:peddi/features/onboarding/domain/placement_result.dart';
import 'package:peddi/features/onboarding/domain/placement_scoring_config.dart';

void main() {
  group('PlacementEvaluator Domain Tests', () {
    const evaluator = StandardPlacementEvaluator();

    test('Threshold boundary: 0 to 3 first-try correct yields Little', () {
      expect(
        evaluator.evaluate(firstTryCorrectCount: 0, totalQuestions: 8),
        LanguageLevel.little,
      );
      expect(
        evaluator.evaluate(firstTryCorrectCount: 3, totalQuestions: 8),
        LanguageLevel.little,
      );
    });

    test('Threshold boundary: 4 to 6 first-try correct yields Know a bit', () {
      expect(
        evaluator.evaluate(firstTryCorrectCount: 4, totalQuestions: 8),
        LanguageLevel.knowABit,
      );
      expect(
        evaluator.evaluate(firstTryCorrectCount: 6, totalQuestions: 8),
        LanguageLevel.knowABit,
      );
    });

    test('Threshold boundary: 7 or more first-try correct yields Expert', () {
      expect(
        evaluator.evaluate(firstTryCorrectCount: 7, totalQuestions: 8),
        LanguageLevel.expert,
      );
      expect(
        evaluator.evaluate(firstTryCorrectCount: 8, totalQuestions: 8),
        LanguageLevel.expert,
      );
      expect(
        evaluator.evaluate(firstTryCorrectCount: 10, totalQuestions: 10),
        LanguageLevel.expert,
      );
    });
  });

  group('LevelInfo Domain Tests', () {
    test(
      'LevelInfo has distinct metadata for Little, Know a bit, and Expert',
      () {
        final little = LevelInfo.forLevel(LanguageLevel.little);
        expect(little.emoji, '🐣');
        expect(little.name, 'Little');
        expect(little.title, "You're a Little learner");

        final knowABit = LevelInfo.forLevel(LanguageLevel.knowABit);
        expect(knowABit.emoji, '🐥');
        expect(knowABit.name, 'Know a bit');
        expect(knowABit.title, "You're a Know a bit learner");

        final expert = LevelInfo.forLevel(LanguageLevel.expert);
        expect(expert.emoji, '🦉');
        expect(expert.name, 'Expert');
        // English grammar verification: "an Expert" instead of "a Expert"
        expect(expert.title, "You're an Expert learner");
      },
    );
  });

  group('PlacementResult.fromSession Domain Tests', () {
    final sampleExercises = [
      const ChooseMeaningExercise(
        id: 'q1',
        prompt: 'Prompt 1',
        audioText: 'Audio 1',
        audioLocale: 'es-ES',
        explanationText: 'Exp 1',
        correctAnswerText: 'Ans 1',
        feedbackSuccessText: 'Succ 1',
        phrase: 'Phrase 1',
        options: [],
        correctOptionId: 'opt1',
        praisePhrase: 'Un café, por favor',
      ),
      const ChooseMeaningExercise(
        id: 'q2',
        prompt: 'Prompt 2',
        audioText: 'Audio 2',
        audioLocale: 'es-ES',
        explanationText: 'Exp 2',
        correctAnswerText: 'Ans 2',
        feedbackSuccessText: 'Succ 2',
        phrase: 'Phrase 2',
        options: [],
        correctOptionId: 'opt2',
        praisePhrase: 'Buenas tardes',
      ),
      const ChooseMeaningExercise(
        id: 'q3',
        prompt: 'Prompt 3',
        audioText: 'Audio 3',
        audioLocale: 'es-ES',
        explanationText: 'Exp 3',
        correctAnswerText: 'Ans 3',
        feedbackSuccessText: 'Succ 3',
        phrase: 'Phrase 3',
        options: [],
        correctOptionId: 'opt3',
        praisePhrase: 'Soy de México',
      ),
      const ChooseMeaningExercise(
        id: 'q4',
        prompt: 'Prompt 4',
        audioText: 'Audio 4',
        audioLocale: 'es-ES',
        explanationText: 'Exp 4',
        correctAnswerText: 'Ans 4',
        feedbackSuccessText: 'Succ 4',
        phrase: 'Phrase 4',
        options: [],
        correctOptionId: 'opt4',
        praisePhrase: 'Extra phrase 4',
      ),
    ];

    test(
      'Collects praise phrases strictly from first-try-correct questions up to max 3',
      () {
        final results = {
          'q1': const ExerciseResult(
            exerciseId: 'q1',
            isFirstTryCorrect: true,
            hintsUsed: 0,
            attempts: 1,
          ),
          'q2': const ExerciseResult(
            exerciseId: 'q2',
            isFirstTryCorrect: false, // Redo succeeded, so NOT first-try
            hintsUsed: 0,
            attempts: 2,
          ),
          'q3': const ExerciseResult(
            exerciseId: 'q3',
            isFirstTryCorrect: true,
            hintsUsed: 0,
            attempts: 1,
          ),
          'q4': const ExerciseResult(
            exerciseId: 'q4',
            isFirstTryCorrect: true,
            hintsUsed: 0,
            attempts: 1,
          ),
        };

        final result = PlacementResult.fromSession(
          exercises: sampleExercises,
          results: results,
        );

        expect(result.firstTryCorrect, 3);
        expect(
          result.suggestedLevel,
          LanguageLevel.little,
        ); // 3 correct -> Little
        expect(result.chosenLevel, LanguageLevel.little);
        expect(result.praisePhrases, [
          'Un café, por favor',
          'Soy de México',
          'Extra phrase 4',
        ]);
        expect(
          result.praisePhrases.length,
          lessThanOrEqualTo(PlacementScoringConfig.maxPraisePhrases),
        );
      },
    );

    test(
      'Empty praise phrases when zero questions answered right on first try',
      () {
        final results = {
          'q1': const ExerciseResult(
            exerciseId: 'q1',
            isFirstTryCorrect: false,
            hintsUsed: 0,
            attempts: 2,
          ),
        };

        final result = PlacementResult.fromSession(
          exercises: sampleExercises,
          results: results,
        );

        expect(result.firstTryCorrect, 0);
        expect(result.praisePhrases, isEmpty);
        expect(result.hasPraisePhrases, isFalse);
      },
    );

    test('Overriding chosen level retains original suggested level', () {
      const original = PlacementResult(
        suggestedLevel: LanguageLevel.expert,
        chosenLevel: LanguageLevel.expert,
        firstTryCorrect: 8,
        totalQuestions: 8,
        praisePhrases: ['Soy de México'],
        streakDay: 1,
      );

      final updated = original.copyWith(chosenLevel: LanguageLevel.knowABit);
      expect(updated.suggestedLevel, LanguageLevel.expert);
      expect(updated.chosenLevel, LanguageLevel.knowABit);
      expect(updated.firstTryCorrect, 8);
      expect(updated.streakDay, 1);
    });
  });
}

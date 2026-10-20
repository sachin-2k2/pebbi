import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/audio_feedback_service.dart';
import 'package:peddi/features/lesson/data/mock_exercise_repository.dart';
import 'package:peddi/features/lesson/domain/answer_checker.dart';
import 'package:peddi/features/lesson/domain/exercise.dart';
import 'package:peddi/features/lesson/domain/picture_option.dart';
import 'package:peddi/features/lesson/domain/sentence_arrangement.dart';
import 'package:peddi/features/lesson/domain/text_option.dart';
import 'package:peddi/features/lesson/domain/word_tile_item.dart';
import 'package:peddi/features/lesson/presentation/providers/exercise_session_notifier.dart';
import 'package:peddi/features/lesson/presentation/providers/exercise_session_state.dart';

void main() {
  group('AnswerChecker Domain Unit Tests', () {
    const checker = StandardAnswerChecker();

    final testExercise = PickPictureExercise(
      id: 'ex_1',
      prompt: 'A ticket to Madrid, please',
      audioText: 'Un billete a Madrid, por favor',
      audioLocale: 'es-ES',
      explanationText: 'Ticket explanation',
      correctAnswerText: 'Un billete a Madrid, por favor',
      feedbackSuccessText: 'Ticket success text',
      correctOptionId: 'opt_ticket',
      options: const [
        PictureOption(id: 'opt_ticket', imageRef: '🎫', spokenLabel: 'ticket'),
        PictureOption(id: 'opt_moon', imageRef: '🌙', spokenLabel: 'moon'),
        PictureOption(id: 'opt_smile', imageRef: '😊', spokenLabel: 'smile'),
        PictureOption(id: 'opt_q', imageRef: '❓', spokenLabel: 'question'),
      ],
    );

    test('returns true for correct option ID', () {
      expect(checker.isCorrect(testExercise, 'opt_ticket'), isTrue);
    });

    test('returns false for wrong option ID', () {
      expect(checker.isCorrect(testExercise, 'opt_moon'), isFalse);
      expect(checker.isCorrect(testExercise, 'opt_smile'), isFalse);
      expect(checker.isCorrect(testExercise, 'unknown'), isFalse);
    });

    test(
      'validates ChooseMeaningExercise correctly via SingleChoiceExercise',
      () {
        const chooseMeaning = ChooseMeaningExercise(
          id: 'ex_choose',
          prompt: 'What does this mean?',
          audioText: 'Soy de México',
          audioLocale: 'es-ES',
          explanationText: 'Origin explanation',
          correctAnswerText: "I'm from Mexico",
          feedbackSuccessText: "Soy de México means I'm from Mexico",
          phrase: 'Soy de México',
          options: [
            TextOption(id: 'opt_1', text: 'How much does it cost?'),
            TextOption(id: 'opt_2', text: 'Sparkling water'),
            TextOption(id: 'opt_3', text: "I'm from Mexico"),
          ],
          correctOptionId: 'opt_3',
        );

        expect(checker.isCorrect(chooseMeaning, 'opt_3'), isTrue);
        expect(checker.isCorrect(chooseMeaning, 'opt_1'), isFalse);
        expect(checker.isCorrect(chooseMeaning, 'opt_2'), isFalse);
      },
    );
  });

  group('ExerciseSessionNotifier Domain & State Machine Tests', () {
    late MockExerciseRepository mockRepo;
    late StandardAnswerChecker answerChecker;
    late FakeAudioFeedbackService fakeAudio;
    late ExerciseSessionNotifier notifier;

    setUp(() {
      mockRepo = const MockExerciseRepository();
      answerChecker = const StandardAnswerChecker();
      fakeAudio = FakeAudioFeedbackService();
      notifier = ExerciseSessionNotifier(
        repository: mockRepo,
        answerChecker: answerChecker,
        audioFeedback: fakeAudio,
      );
    });

    test('initializes with placement exercises in idle state', () async {
      await notifier.loadPlacement('es');

      final state = notifier.state;
      expect(state.mainExercises.length, equals(8));
      expect(state.currentMainIndex, equals(0));
      expect(state.status, equals(ExerciseStatus.idle));
      expect(state.selectedOptionId, isNull);
      expect(state.canCheck, isFalse);
      expect(state.canUseHint, isTrue);
    });

    test(
      'selecting an option enables Check and single selection works',
      () async {
        await notifier.loadPlacement('es');

        notifier.selectOption('opt_ticket');
        expect(notifier.state.status, equals(ExerciseStatus.selected));
        expect(notifier.state.selectedOptionId, equals('opt_ticket'));
        expect(notifier.state.canCheck, isTrue);

        // Tapping selected option again does NOT deselect it
        notifier.selectOption('opt_ticket');
        expect(notifier.state.selectedOptionId, equals('opt_ticket'));
        expect(notifier.state.canCheck, isTrue);

        // Can switch to another option before check
        notifier.selectOption('opt_moon');
        expect(notifier.state.selectedOptionId, equals('opt_moon'));
      },
    );

    test(
      'useHint removes one wrong distractor, never correct and never selected',
      () async {
        await notifier.loadPlacement('es');

        // Select 'opt_moon' (wrong option)
        notifier.selectOption('opt_moon');
        expect(notifier.state.canUseHint, isTrue);

        // Use Hint
        notifier.useHint();

        final state = notifier.state;
        expect(state.removedOptionIds.length, equals(1));
        expect(state.hintsUsed, equals(1));

        final removedId = state.removedOptionIds.first;
        // Must NOT be the correct option (opt_ticket)
        expect(removedId, isNot(equals('opt_ticket')));
        // Must NOT be the currently selected option (opt_moon)
        expect(removedId, isNot(equals('opt_moon')));

        // Cannot select a removed option
        notifier.selectOption(removedId);
        expect(notifier.state.selectedOptionId, equals('opt_moon'));
      },
    );

    test('hint disables when only 2 options remain', () async {
      await notifier.loadPlacement('es');

      // 4 options initially
      notifier.useHint(); // 3 options remain
      expect(notifier.state.canUseHint, isTrue);

      notifier.useHint(); // 2 options remain
      expect(notifier.state.canUseHint, isFalse);

      // Subsequent hint call does nothing
      notifier.useHint();
      expect(notifier.state.hintsUsed, equals(2));
    });

    test(
      'checkAnswer with correct option triggers success feedback and does not queue redo',
      () async {
        await notifier.loadPlacement('es');

        notifier.selectOption('opt_ticket');
        await notifier.checkAnswer();

        final state = notifier.state;
        expect(state.status, equals(ExerciseStatus.checked));
        expect(state.feedbackKind, equals(FeedbackKind.correct));
        expect(state.redoQueue, isEmpty);
        expect(fakeAudio.successCount, equals(1));
        expect(fakeAudio.wrongCount, equals(0));

        final result = state.results['placement_1'];
        expect(result, isNotNull);
        expect(result!.isFirstTryCorrect, isTrue);
        expect(result.attempts, equals(1));
      },
    );

    test(
      'checkAnswer with wrong option triggers error feedback and appends to redo queue',
      () async {
        await notifier.loadPlacement('es');

        notifier.selectOption('opt_moon'); // Wrong
        await notifier.checkAnswer();

        final state = notifier.state;
        expect(state.status, equals(ExerciseStatus.checked));
        expect(state.feedbackKind, equals(FeedbackKind.wrong));
        expect(state.redoQueue.length, equals(1));
        expect(state.redoQueue.first.id, equals('placement_1'));
        expect(fakeAudio.wrongCount, equals(1));

        final result = state.results['placement_1'];
        expect(result, isNotNull);
        expect(result!.isFirstTryCorrect, isFalse);
        expect(result.attempts, equals(1));
      },
    );

    test(
      'redo queue re-plays failed questions after main set and terminates without loop',
      () async {
        await notifier.loadPlacement('es');

        // Answer question 1 WRONG
        notifier.selectOption('opt_moon');
        await notifier.checkAnswer();
        expect(notifier.state.redoQueue.length, equals(1));

        // Advance through questions 2 to 8 correctly
        for (int i = 1; i < 8; i++) {
          notifier.next();
          final currentEx = notifier.state.currentExercise!;
          if (currentEx is SingleChoiceExercise) {
            final singleChoice = currentEx as SingleChoiceExercise;
            notifier.selectOption(singleChoice.correctOptionId);
          } else if (currentEx is BuildSentenceExercise) {
            for (final tileId in currentEx.acceptedAnswers.first) {
              notifier.placeTile(tileId);
            }
          }
          await notifier.checkAnswer();
        }

        expect(notifier.state.currentMainIndex, equals(7));

        // Tap next on last question -> enters Redo Round!
        notifier.next();
        expect(notifier.state.isRedoRound, isTrue);
        expect(notifier.state.currentRedoIndex, equals(0));
        expect(notifier.state.currentExercise!.id, equals('placement_1'));

        // In redo round: answer WRONG again
        notifier.selectOption('opt_moon');
        await notifier.checkAnswer();

        // Question is NOT added again to redo queue per spec
        expect(notifier.state.redoQueue.length, equals(1));

        // Next finishes the session
        notifier.next();
        expect(notifier.state.status, equals(ExerciseStatus.completed));
      },
    );

    test(
      'useHint on ChooseMeaningExercise eliminates 1 of 3 options and then disables hint',
      () async {
        await notifier.loadPlacement('es');

        // Advance to Q4 (ChooseMeaningExercise)
        for (int i = 0; i < 3; i++) {
          final ex = notifier.state.currentExercise as SingleChoiceExercise;
          notifier.selectOption(ex.correctOptionId);
          await notifier.checkAnswer();
          notifier.next();
        }

        expect(notifier.state.currentMainIndex, equals(3));
        expect(notifier.state.currentExercise, isA<ChooseMeaningExercise>());
        expect(notifier.state.canUseHint, isTrue);

        // Select the correct option first
        notifier.selectOption('q4_opt3');

        // Use hint -> eliminates 1 wrong option (q4_opt1 or q4_opt2)
        notifier.useHint();
        expect(notifier.state.hintsUsed, equals(1));
        expect(notifier.state.removedOptionIds.length, equals(1));
        expect(notifier.state.removedOptionIds.contains('q4_opt3'), isFalse);

        // Exactly 2 options remain (1 correct + 1 distractor), so hint is now disabled
        expect(notifier.state.canUseHint, isFalse);
      },
    );

    test(
      'BuildSentenceExercise placeTile, removeTile, and checkAnswer flow',
      () async {
        await notifier.loadPlacement('es');

        // Advance to Q7 (BuildSentenceExercise)
        for (int i = 0; i < 6; i++) {
          final ex = notifier.state.currentExercise as SingleChoiceExercise;
          notifier.selectOption(ex.correctOptionId);
          await notifier.checkAnswer();
          notifier.next();
        }

        expect(notifier.state.currentMainIndex, equals(6));
        expect(notifier.state.currentExercise, isA<BuildSentenceExercise>());
        expect(notifier.state.status, equals(ExerciseStatus.idle));
        expect(notifier.state.canCheck, isFalse);

        // Place a tile: "Ida"
        notifier.placeTile('q7_tile_ida');
        expect(notifier.state.placedTileIds, equals(['q7_tile_ida']));
        expect(notifier.state.status, equals(ExerciseStatus.selected));
        expect(notifier.state.canCheck, isTrue);

        // Remove the tile: returns to empty and idle
        notifier.removeTile('q7_tile_ida');
        expect(notifier.state.placedTileIds, isEmpty);
        expect(notifier.state.status, equals(ExerciseStatus.idle));
        expect(notifier.state.canCheck, isFalse);

        // Build the correct sentence: "Ida y vuelta"
        notifier.placeTile('q7_tile_ida');
        notifier.placeTile('q7_tile_y');
        notifier.placeTile('q7_tile_vuelta');
        expect(notifier.state.canCheck, isTrue);

        await notifier.checkAnswer();
        expect(notifier.state.status, equals(ExerciseStatus.checked));
        expect(notifier.state.feedbackKind, equals(FeedbackKind.correct));
        expect(notifier.state.redoQueue, isEmpty);
      },
    );
  });

  group('SentenceArrangement & AnswerChecker Domain Unit Tests', () {
    const tiles = [
      WordTileItem(id: 't_ida', text: 'Ida'),
      WordTileItem(id: 't_y', text: 'y'),
      WordTileItem(id: 't_vuelta', text: 'vuelta'),
      WordTileItem(id: 't_a', text: 'A'),
    ];

    test('SentenceArrangement place, remove, reset work correctly', () {
      var arr = const SentenceArrangement(allTiles: tiles);
      expect(arr.placedTileIds, isEmpty);
      expect(arr.assembledSentence, isEmpty);

      arr = arr.place('t_ida').place('t_y').place('t_vuelta');
      expect(arr.placedTileIds, equals(['t_ida', 't_y', 't_vuelta']));
      expect(arr.assembledSentence, equals('Ida y vuelta'));
      expect(arr.isPlaced('t_ida'), isTrue);
      expect(arr.isPlaced('t_a'), isFalse);

      // Remove middle tile
      arr = arr.remove('t_y');
      expect(arr.placedTileIds, equals(['t_ida', 't_vuelta']));
      expect(arr.assembledSentence, equals('Ida vuelta'));

      // Reset
      arr = arr.reset();
      expect(arr.placedTileIds, isEmpty);
    });

    test('StandardAnswerChecker validates BuildSentenceExercise correctly', () {
      const checker = StandardAnswerChecker();
      const exercise = BuildSentenceExercise(
        id: 'q7',
        prompt: 'Return ticket',
        audioText: 'Ida y vuelta',
        audioLocale: 'es-ES',
        explanationText: 'Explanation',
        correctAnswerText: 'Ida y vuelta',
        feedbackSuccessText: 'Success',
        tiles: tiles,
        acceptedAnswers: [
          ['t_ida', 't_y', 't_vuelta'],
        ],
      );

      // Correct order
      expect(
        checker.isSentenceCorrect(exercise, ['t_ida', 't_y', 't_vuelta']),
        isTrue,
      );

      // Incomplete
      expect(checker.isSentenceCorrect(exercise, ['t_ida', 't_y']), isFalse);

      // Wrong order
      expect(
        checker.isSentenceCorrect(exercise, ['t_vuelta', 't_y', 't_ida']),
        isFalse,
      );

      // Including distractor
      expect(
        checker.isSentenceCorrect(exercise, [
          't_a',
          't_ida',
          't_y',
          't_vuelta',
        ]),
        isFalse,
      );

      // Empty
      expect(checker.isSentenceCorrect(exercise, []), isFalse);
    });
  });
}

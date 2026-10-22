import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/lesson/domain/exercise.dart';
import 'package:peddi/features/lesson/domain/match_pair_item.dart';
import 'package:peddi/features/lesson/domain/match_pairs_logic.dart';

void main() {
  group('MatchPairsLogic domain unit tests', () {
    const pair1 = MatchPairItem(
      id: 'p1',
      targetText: 'Hola',
      meaningText: 'Hello',
    );
    const pair2 = MatchPairItem(
      id: 'p2',
      targetText: 'Adiós',
      meaningText: 'Goodbye',
    );
    const exercise = MatchPairsExercise(
      id: 'm1',
      prompt: 'Match the pairs',
      pairs: [pair1, pair2],
      displayMeaningIds: ['p2', 'p1'],
      explanationText: 'Greeting pairs',
      correctAnswerText: 'Hola - Hello, Adiós - Goodbye',
      feedbackSuccessText: 'All matched!',
    );

    test('isPairMatch returns true when IDs match', () {
      expect(MatchPairsLogic.isPairMatch('p1', 'p1'), isTrue);
      expect(MatchPairsLogic.isPairMatch('p2', 'p2'), isTrue);
    });

    test('isPairMatch returns false when IDs mismatch', () {
      expect(MatchPairsLogic.isPairMatch('p1', 'p2'), isFalse);
      expect(MatchPairsLogic.isPairMatch('p2', 'p1'), isFalse);
    });

    test('isAllMatched returns true only when all pairs are matched', () {
      expect(
        MatchPairsLogic.isAllMatched(
          exercise: exercise,
          matchedPairIds: {'p1'},
        ),
        isFalse,
      );
      expect(
        MatchPairsLogic.isAllMatched(
          exercise: exercise,
          matchedPairIds: {'p1', 'p2'},
        ),
        isTrue,
      );
    });
  });
}

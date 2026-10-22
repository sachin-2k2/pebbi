import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/lesson/domain/lesson_result.dart';

void main() {
  group('LessonResult domain unit tests', () {
    test('computes first-try accuracy and mistakes correctly', () {
      final records = {
        'item_1': const ItemRecord(
          itemId: 'item_1',
          seen: true,
          firstTryCorrect: null,
        ), // teach card
        'item_2': const ItemRecord(
          itemId: 'item_2',
          seen: true,
          firstTryCorrect: true,
        ),
        'item_3': const ItemRecord(
          itemId: 'item_3',
          seen: true,
          firstTryCorrect: false,
          attempts: 2,
        ),
        'item_4': const ItemRecord(
          itemId: 'item_4',
          seen: true,
          skipped: true,
          firstTryCorrect: null,
        ),
        'item_5': const ItemRecord(
          itemId: 'item_5',
          seen: true,
          firstTryCorrect: true,
        ),
      };

      final result = LessonResult(
        stopId: '1',
        userId: 'user_test',
        totalItems: 5,
        itemRecords: records,
        completedAt: DateTime.now(),
      );

      // Scored items are those with non-null firstTryCorrect: item_2, item_3, item_5 (3 items)
      expect(result.scoredItemCount, equals(3));
      // First try correct: item_2, item_5 (2 items)
      expect(result.firstTryCorrectCount, equals(2));
      // Percentage: 2/3 * 100 = 67%
      expect(result.firstTryPercentage, equals(67));
      // Mistakes: item_3 (1 item)
      expect(result.totalMistakes, equals(1));
    });

    test('returns 100% when no items were scored (e.g. only teach cards)', () {
      final records = {
        'item_1': const ItemRecord(
          itemId: 'item_1',
          seen: true,
          firstTryCorrect: null,
        ),
      };

      final result = LessonResult(
        stopId: '1',
        userId: 'user_test',
        totalItems: 1,
        itemRecords: records,
        completedAt: DateTime.now(),
      );

      expect(result.scoredItemCount, equals(0));
      expect(result.firstTryPercentage, equals(100));
    });
  });
}

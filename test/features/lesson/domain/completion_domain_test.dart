import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/lesson/data/mock_progress_repository.dart';
import 'package:peddi/features/lesson/domain/lesson_completion.dart';
import 'package:peddi/features/lesson/domain/lesson_result.dart';

void main() {
  group('Lesson Completion Domain Tests', () {
    test('LearnedPhrase model holds phrase metadata and RTL', () {
      const phrase = LearnedPhrase(
        id: 'p1',
        emoji: '👋',
        text: 'مرحبا',
        meaning: 'Hello',
        audioText: 'مرحبا',
        audioLocale: 'ar-SA',
        isRtl: true,
      );

      expect(phrase.id, 'p1');
      expect(phrase.emoji, '👋');
      expect(phrase.text, 'مرحبا');
      expect(phrase.meaning, 'Hello');
      expect(phrase.isRtl, isTrue);
    });

    test('DailyGoalCompletion correctly identifies completion status', () {
      const goalDone = DailyGoalCompletion(status: DailyGoalStatus.done);
      expect(goalDone.isDone, isTrue);
      expect(goalDone.isInProgress, isFalse);

      const goalInProgress = DailyGoalCompletion(
        status: DailyGoalStatus.inProgress,
        progressText: '1 of 2 lessons left',
      );
      expect(goalInProgress.isDone, isFalse);
      expect(goalInProgress.isInProgress, isTrue);
      expect(goalInProgress.progressText, '1 of 2 lessons left');
    });

    test('Star calculation awards 3 stars for >= 90% first-try accuracy', () async {
      final repo = MockProgressRepository();
      final result = LessonResult(
        stopId: 'stop_1',
        userId: 'u1',
        totalItems: 10,
        itemRecords: {
          for (int i = 0; i < 9; i++)
            'item_$i': ItemRecord(itemId: 'item_$i', firstTryCorrect: true),
          'item_9': const ItemRecord(itemId: 'item_9', firstTryCorrect: false),
        },
        completedAt: DateTime.now(),
      );

      final completion = await repo.completeLesson(
        userId: 'u1',
        stopId: 'stop_1',
        result: result,
        clientEventId: 'evt_1',
      );

      expect(completion.starsEarned, 3);
      expect(completion.firstTryCorrectCount, 9);
      expect(completion.scoredCount, 10);
    });

    test('Star calculation awards 2 stars for 60% to 89% accuracy', () async {
      final repo = MockProgressRepository();
      final result = LessonResult(
        stopId: 'stop_2',
        userId: 'u1',
        totalItems: 10,
        itemRecords: {
          for (int i = 0; i < 7; i++)
            'item_$i': ItemRecord(itemId: 'item_$i', firstTryCorrect: true),
          for (int i = 7; i < 10; i++)
            'item_$i': ItemRecord(itemId: 'item_$i', firstTryCorrect: false),
        },
        completedAt: DateTime.now(),
      );

      final completion = await repo.completeLesson(
        userId: 'u1',
        stopId: 'stop_2',
        result: result,
        clientEventId: 'evt_2',
      );

      expect(completion.starsEarned, 2);
    });

    test('Star calculation awards 1 star for < 60% accuracy', () async {
      final repo = MockProgressRepository();
      final result = LessonResult(
        stopId: 'stop_3',
        userId: 'u1',
        totalItems: 10,
        itemRecords: {
          for (int i = 0; i < 4; i++)
            'item_$i': ItemRecord(itemId: 'item_$i', firstTryCorrect: true),
          for (int i = 4; i < 10; i++)
            'item_$i': ItemRecord(itemId: 'item_$i', firstTryCorrect: false),
        },
        completedAt: DateTime.now(),
      );

      final completion = await repo.completeLesson(
        userId: 'u1',
        stopId: 'stop_3',
        result: result,
        clientEventId: 'evt_3',
      );

      expect(completion.starsEarned, 1);
    });

    test('Star calculation awards 0 stars if all exercises are skipped', () async {
      final repo = MockProgressRepository();
      final result = LessonResult(
        stopId: 'stop_4',
        userId: 'u1',
        totalItems: 3,
        itemRecords: {
          for (int i = 0; i < 3; i++)
            'item_$i': ItemRecord(itemId: 'item_$i', skipped: true),
        },
        completedAt: DateTime.now(),
      );

      final completion = await repo.completeLesson(
        userId: 'u1',
        stopId: 'stop_4',
        result: result,
        clientEventId: 'evt_4',
      );

      expect(completion.starsEarned, 0);
    });

    test('completeLesson is strictly idempotent by stopId and clientEventId', () async {
      final repo = MockProgressRepository();
      final result = LessonResult(
        stopId: 'stop_10',
        userId: 'user_a',
        totalItems: 5,
        itemRecords: {
          for (int i = 0; i < 5; i++)
            'item_$i': ItemRecord(itemId: 'item_$i', firstTryCorrect: true),
        },
        completedAt: DateTime.now(),
      );

      final first = await repo.completeLesson(
        userId: 'user_a',
        stopId: 'stop_10',
        result: result,
        clientEventId: 'event_uuid_100',
      );

      final second = await repo.completeLesson(
        userId: 'user_a',
        stopId: 'stop_10',
        result: result,
        clientEventId: 'event_uuid_100',
      );

      expect(identical(first, second), isTrue);
      expect(repo.outbox.length, 1);
    });

    test('User isolation: progress of user_a does not leak to user_b', () async {
      final repo = MockProgressRepository();
      final resultA = LessonResult(
        stopId: 'stop_common',
        userId: 'user_a',
        totalItems: 3,
        itemRecords: {
          'it_1': const ItemRecord(itemId: 'it_1', firstTryCorrect: true),
        },
        completedAt: DateTime.now(),
      );

      await repo.completeLesson(
        userId: 'user_a',
        stopId: 'stop_common',
        result: resultA,
        clientEventId: 'evt_a',
      );

      expect(await repo.isStopCompleted(userId: 'user_a', stopId: 'stop_common'), isTrue);
      expect(await repo.isStopCompleted(userId: 'user_b', stopId: 'stop_common'), isFalse);
    });
  });
}

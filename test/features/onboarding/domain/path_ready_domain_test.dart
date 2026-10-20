import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/onboarding/data/mock_path_preparation_service.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/first_lesson_info.dart';
import 'package:peddi/features/onboarding/domain/path_ready_config.dart';
import 'package:peddi/features/onboarding/domain/preparation_task.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';

void main() {
  group('PathReadyConfig & Thresholds', () {
    test('thresholds increase monotonically up to 1.0', () {
      expect(PathReadyConfig.task1Threshold, equals(0.33));
      expect(PathReadyConfig.task2Threshold, equals(0.66));
      expect(PathReadyConfig.task3Threshold, equals(1.00));
      expect(
        PathReadyConfig.task1Threshold,
        lessThan(PathReadyConfig.task2Threshold),
      );
      expect(
        PathReadyConfig.task2Threshold,
        lessThan(PathReadyConfig.task3Threshold),
      );
    });

    test('ring diameter bounds are positive and ordered', () {
      expect(PathReadyConfig.minRingDiameter, equals(140.0));
      expect(PathReadyConfig.maxRingDiameter, equals(200.0));
      expect(
        PathReadyConfig.minRingDiameter,
        lessThan(PathReadyConfig.maxRingDiameter),
      );
    });
  });

  group('MockPathPreparationService Execution', () {
    test('emits snapshots up to 100% with all tasks done', () async {
      const service = MockPathPreparationService(
        totalDuration: Duration(milliseconds: 200),
        tickInterval: Duration(milliseconds: 50),
      );

      final events = await service.startPreparation().toList();
      expect(events, isNotEmpty);

      // Initial event at 0.0
      expect(events.first.progress, equals(0.0));
      expect(events.first.isComplete, isFalse);
      expect(
        events.first.tasks.every((t) => t.status == TaskStatus.pending),
        isTrue,
      );

      // Final event at 1.0
      expect(events.last.progress, equals(1.0));
      expect(events.last.isComplete, isTrue);
      expect(
        events.last.tasks.every((t) => t.status == TaskStatus.done),
        isTrue,
      );
    });

    test('reduceMotion immediately finishes with 1.0 progress', () async {
      const service = MockPathPreparationService(
        totalDuration: Duration(seconds: 10),
      );

      final events = await service
          .startPreparation(reduceMotion: true)
          .toList();
      expect(events.length, equals(2));
      expect(events.last.progress, equals(1.0));
      expect(events.last.isComplete, isTrue);
      expect(
        events.last.tasks.every((t) => t.status == TaskStatus.done),
        isTrue,
      );
    });

    test('simulates failed task correctly', () async {
      const service = MockPathPreparationService(
        totalDuration: Duration(milliseconds: 100),
        tickInterval: Duration(milliseconds: 25),
        failedTaskId: 'audio',
      );

      final events = await service.startPreparation().toList();
      final audioTask = events.last.tasks.firstWhere((t) => t.id == 'audio');
      expect(audioTask.status, equals(TaskStatus.failed));
      expect(audioTask.errorMessage, isNotNull);

      // Other tasks still succeed
      final stickerTask = events.last.tasks.firstWhere(
        (t) => t.id == 'sticker',
      );
      expect(stickerTask.status, equals(TaskStatus.done));
    });

    test('simulates unavailable task correctly', () async {
      const service = MockPathPreparationService(
        totalDuration: Duration(milliseconds: 100),
        tickInterval: Duration(milliseconds: 25),
        unavailableTaskId: 'speaking',
      );

      final events = await service.startPreparation().toList();
      final speakingTask = events.last.tasks.firstWhere(
        (t) => t.id == 'speaking',
      );
      expect(speakingTask.status, equals(TaskStatus.unavailable));
    });
  });

  group('UserProfile Privacy & Isolation Compliance', () {
    test('stores only privacy-safe ageBand, never birth year', () {
      final profile = UserProfile(
        userId: 'guest_test_123',
        ageBand: AgeBand.adult,
        explanationLanguageCode: 'en',
        targetLanguageCode: 'es',
        reasonIds: const {'travel'},
        dailyGoalId: 'regular',
        reminderTime: ReminderTime.defaultTime,
        selectedWeekdayNumbers: const {1, 2, 3, 4, 5},
        remindersEnabled: true,
        accentId: 'violet',
        plan: 'free',
        isOnboarded: true,
      );

      expect(profile.userId, 'guest_test_123');
      expect(profile.ageBand, AgeBand.adult);
      expect(profile.isOnboarded, isTrue);
      expect(profile.plan, 'free');
    });

    test(
      'FirstLessonInfo and PreparationTask equality and hashCode work correctly',
      () {
        const lesson1 = FirstLessonInfo(lessonNumber: 1, estimatedMinutes: 3);
        const lesson2 = FirstLessonInfo(lessonNumber: 1, estimatedMinutes: 3);
        const lesson3 = FirstLessonInfo(lessonNumber: 2, estimatedMinutes: 5);

        expect(lesson1, equals(lesson2));
        expect(lesson1.hashCode, equals(lesson2.hashCode));
        expect(lesson1, isNot(equals(lesson3)));

        const task1 = PreparationTask(id: 'a', label: 'A', emoji: '🎧');
        const task2 = PreparationTask(id: 'a', label: 'A', emoji: '🎧');
        const task3 = PreparationTask(id: 'b', label: 'B', emoji: '👋');

        expect(task1, equals(task2));
        expect(task1.hashCode, equals(task2.hashCode));
        expect(task1, isNot(equals(task3)));
      },
    );
  });
}

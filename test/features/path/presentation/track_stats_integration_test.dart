import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/data/dtos/user_profile_dto.dart';
import 'package:peddi/features/lesson/data/dtos/submit_lesson_dto.dart';
import 'package:peddi/features/path/data/dtos/track_response_dto.dart';
import 'package:peddi/features/path/presentation/providers/home_summary_provider.dart';
import 'package:peddi/features/path/presentation/providers/track_stats_provider.dart';

void main() {
  group('Track & User Stats Integration Tests (Option A, B, C)', () {
    test('TrackResponseDto parses user_streak, total_stars, and total_xp (Option A)', () {
      final json = {
        'track_id': 'daily',
        'user_streak': 1,
        'total_stars': 20,
        'total_xp': 20,
        'lessons': [
          {
            'lesson_id': 'daily-starter-1',
            'lesson_number': 1,
            'level': 'starter',
            'title': 'Say Hello',
            'status': 'complete',
            'locked': false,
          }
        ]
      };

      final dto = TrackResponseDto.fromJson(json);
      expect(dto.trackId, equals('daily'));
      expect(dto.userStreak, equals(1));
      expect(dto.totalStars, equals(20));
      expect(dto.totalXp, equals(20));
      expect(dto.lessons.length, equals(1));
    });

    test('UserProfileDto parses current_streak, total_stars, and total_xp (Option B)', () {
      final json = {
        'id': 'user_123',
        'email': 'user@example.com',
        'display_name': 'Test User',
        'native_language': 'en',
        'learning_language': 'es',
        'current_streak': 1,
        'total_stars': 20,
        'total_xp': 20,
      };

      final dto = UserProfileDto.fromJson(json);
      expect(dto.currentStreak, equals(1));
      expect(dto.totalStars, equals(20));
      expect(dto.totalXp, equals(20));

      final domain = dto.toDomain();
      expect(domain.currentStreak, equals(1));
      expect(domain.totalStars, equals(20));
      expect(domain.totalXp, equals(20));
    });

    test('SubmitLessonResponseDto parses current_streak, total_stars, and total_xp (Option C)', () {
      final json = {
        'passed': true,
        'score': 6,
        'total': 6,
        'score_pct': 100,
        'xp_awarded': 10,
        'total_xp': 20,
        'total_stars': 20,
        'current_streak': 1,
        'next_lesson_id': 'daily-starter-2',
        'pebbi_says': '¡Perfecto! 🎉 You scored 6/6! Keep going!',
      };

      final dto = SubmitLessonResponseDto.fromJson(json);
      expect(dto.passed, isTrue);
      expect(dto.xpAwarded, equals(10));
      expect(dto.totalXp, equals(20));
      expect(dto.totalStars, equals(20));
      expect(dto.currentStreak, equals(1));
    });

    test('homeSummaryProvider reflects trackStats updates immediately for Path top pills', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initially default
      final initialSummary = await container.read(homeSummaryProvider.future);
      expect(initialSummary.streakCount, equals(0));
      expect(initialSummary.starsCount, equals(0));

      // Update trackStats as done when GET /api/lessons/track/{track_id} returns
      container.read(trackStatsProvider.notifier).update(
            streak: 1,
            stars: 20,
            xp: 20,
          );

      // Re-read summary
      final updatedSummary = await container.read(homeSummaryProvider.future);
      expect(updatedSummary.streakCount, equals(1));
      expect(updatedSummary.starsCount, equals(20));
    });
  });
}


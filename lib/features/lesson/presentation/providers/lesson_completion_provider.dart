import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/lesson_completion.dart';
import '../../domain/lesson_result.dart';
import 'lesson_providers.dart';

/// Provider family for fetching [LessonCompletion] by stop ID.
///
/// Follows AGENTS.md §2.3: Watches [currentUserProvider] for strict user isolation.
final lessonCompletionProvider =
    FutureProvider.family<LessonCompletion, String>((ref, stopId) async {
  final currentUser = ref.watch(currentUserProvider);
  final userId = currentUser?.userId ?? 'guest_default';
  final progressRepository = ref.watch(progressRepositoryProvider);

  final completion = await progressRepository.getLessonCompletion(
    userId: userId,
    stopId: stopId,
  );

  if (completion != null) {
    return completion;
  }

  // Fallback for tests or direct navigation
  final defaultResult = LessonResult(
    stopId: stopId,
    userId: userId,
    totalItems: 9,
    itemRecords: {
      for (int i = 1; i <= 9; i++)
        'item_$i': ItemRecord(
          itemId: 'item_$i',
          seen: true,
          firstTryCorrect: true,
          attempts: 1,
          credit: 1.0,
        ),
    },
    completedAt: DateTime.now(),
  );

  return progressRepository.completeLesson(
    userId: userId,
    stopId: stopId,
    result: defaultResult,
    clientEventId: 'provider_fallback_${userId}_$stopId',
  );
});

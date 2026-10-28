import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../onboarding/domain/placement_answer.dart';
import '../../../onboarding/domain/placement_result.dart';
import '../../../onboarding/presentation/providers/onboarding_flow_provider.dart';
import '../../../onboarding/presentation/providers/placement_repository_provider.dart';
import '../../domain/exercise.dart';
import '../providers/exercise_session_state.dart';
import '../providers/lesson_providers.dart';
import '../widgets/exercise/exit_confirm_sheet.dart';

/// Navigation and exit handling helpers for [ExerciseScreen].
///
/// Follows AGENTS.md §3: keeps screen file under 150 lines.
abstract final class ExerciseScreenNavigation {
  /// Confirms and handles user exit from an active exercise.
  static Future<void> handleExit(
    BuildContext context, {
    required String? stopId,
  }) async {
    final leave = await ExitConfirmSheet.show(context);
    if (!leave || !context.mounted) return;
    if (context.canPop()) {
      context.pop();
    } else if (stopId != null) {
      context.go('/');
    } else {
      context.go('/onboarding/setup/step-6');
    }
  }

  /// Handles completion of an exercise session (curriculum lesson or placement).
  static void handleCompleted(
    BuildContext context,
    WidgetRef ref, {
    required String? stopId,
    required String? finishRoute,
    required VoidCallback? onCompleted,
  }) {
    final session = ref.read(exerciseSessionProvider);
    if (session.status != ExerciseStatus.completed) return;

    if (stopId != null) {
      onCompleted?.call();
      if (onCompleted == null && context.mounted) {
        try {
          context.go(finishRoute ?? '/lesson/$stopId/finish');
        } catch (_) {}
      }
    } else {
      final result = PlacementResult.fromSession(
        exercises: session.mainExercises,
        results: session.results,
      );
      ref
          .read(onboardingFlowProvider.notifier)
          .recordPlacementEvaluation(result);

      _submitToBackend(ref, session);

      onCompleted?.call();
      if (onCompleted == null && context.mounted) {
        try {
          context.go(finishRoute ?? '/onboarding/placement-results');
        } catch (_) {}
      }
    }
  }

  static void _submitToBackend(WidgetRef ref, ExerciseSessionState session) {
    try {
      final repo = ref.read(placementRepositoryProvider);
      final onboarding = ref.read(onboardingFlowProvider);
      final answers = <PlacementAnswer>[];
      for (final ex in session.mainExercises) {
        if (ex is PickPictureExercise) {
          final res = session.results[ex.id];
          final chosenId = res?.selectedOptionId ?? ex.correctOptionId;
          final opt = ex.options.firstWhere(
            (o) => o.id == chosenId,
            orElse: () => ex.options.first,
          );
          answers.add(PlacementAnswer(questionId: ex.id, chosenEmoji: opt.imageRef));
        }
      }
      if (answers.isNotEmpty) {
        Future<void>(() async {
          try {
            await repo.submitAnswers(
              nativeLanguage: onboarding.explanationLanguageCode,
              answers: answers,
            );
          } catch (_) {}
        });
      }
    } catch (_) {}
  }
}

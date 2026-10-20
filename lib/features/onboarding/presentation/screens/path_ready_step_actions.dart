import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/onboarding/domain/first_lesson_info.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/providers/path_ready_provider.dart';

/// Navigation and completion action handlers for Step 11: Path Ready.
///
/// Follows AGENTS.md §2.2 & §3.1: Separates action logic from thin screen scaffold.
abstract final class PathReadyStepActions {
  /// Finishes onboarding: stores profile in guest storage, clears draft,
  /// and navigates to the initial lesson placeholder route.
  static Future<void> onStartLesson({
    required BuildContext context,
    required WidgetRef ref,
    required FirstLessonInfo lessonInfo,
  }) async {
    final answers = ref.read(onboardingFlowProvider);
    final profileRepo = ref.read(profileRepositoryProvider);

    final success = await ref
        .read(pathReadyProvider.notifier)
        .finishOnboarding(answers: answers, profileRepo: profileRepo);

    if (!context.mounted) return;

    if (success) {
      // Clear in-progress onboarding draft
      ref.read(onboardingFlowProvider.notifier).reset();

      // Prompt sign-in, redirecting to Home Path screen upon authentication
      context.go('/login?returnTo=/path');
    } else {
      final error = ref.read(pathReadyProvider).saveErrorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  /// Retries preparation tasks upon network or service failure.
  static void onRetry(WidgetRef ref) {
    ref.read(pathReadyProvider.notifier).retry();
  }
}

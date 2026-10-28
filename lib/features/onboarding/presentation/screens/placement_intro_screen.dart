import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/onboarding_config.dart';
import '../providers/onboarding_flow_provider.dart';
import '../providers/placement_quiz_provider.dart';
import '../widgets/placement_intro_content.dart';
import '../widgets/step_bottom_bar.dart';
import '../widgets/step_footer_button.dart';
import '../widgets/step_progress_header.dart';
import '../widgets/step_scaffold.dart';

/// Onboarding Setup Step 6 of 11: Placement Intro ("Let's see what you already know").
///
/// Follows AGENTS.md §3 & §4: under 150 lines, responsive, prefetch questions,
/// non-blocking skip, tolerant of offline/timeout/unavailable states.
class PlacementIntroScreen extends ConsumerWidget {
  const PlacementIntroScreen({
    super.key,
    this.onStartQuiz,
    this.onSkipToLevel,
    this.onBack,
  });

  final VoidCallback? onStartQuiz;
  final VoidCallback? onSkipToLevel;
  final VoidCallback? onBack;

  void _handleStartQuiz(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.read(placementQuestionsProvider);

    if (questionsAsync.hasValue) {
      final questionSet = questionsAsync.value!;
      if (!questionSet.isAvailable) {
        _handleUnavailable(context, ref, questionSet.unavailableMessage);
        return;
      }
      ref.read(onboardingFlowProvider.notifier).setStep(6);
      ref.read(placementQuizProvider.notifier).initQuestions(questionSet);
    } else {
      ref.read(onboardingFlowProvider.notifier).setStep(6);
    }

    if (onStartQuiz != null) {
      onStartQuiz!();
    } else {
      context.go('/onboarding/placement-quiz');
    }
  }

  void _handleUnavailable(
    BuildContext context,
    WidgetRef ref,
    String? message,
  ) {
    final notifier = ref.read(onboardingFlowProvider.notifier);
    notifier.skipPlacementWithLevel(OnboardingConfig.defaultLowestLevel);
    notifier.setStep(7);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ??
              'Placement quiz unavailable for this language. Starting at Little.',
        ),
      ),
    );

    if (onSkipToLevel != null) {
      onSkipToLevel!();
    } else {
      context.go('/onboarding/setup/step-7');
    }
  }

  void _handleSkip(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingFlowProvider.notifier);
    notifier.skipPlacementWithLevel(OnboardingConfig.defaultLowestLevel);
    notifier.setStep(7);

    if (onSkipToLevel != null) {
      onSkipToLevel!();
    } else {
      context.go('/onboarding/setup/step-7');
    }
  }

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/onboarding/setup/step-5');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(onboardingFlowProvider);
    final hasPlacement = flowState.targetLanguageHasPlacement;

    final questionsAsync =
        hasPlacement ? ref.watch(placementQuestionsProvider) : null;
    final isLoading = questionsAsync?.isLoading ?? false;
    final hasError = questionsAsync?.hasError ?? false;

    return StepScaffold(
      header: StepProgressHeader(
        currentStep: 6,
        onBack: () => _handleBack(context),
      ),
      footer: StepBottomBar(
        button: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasPlacement) ...[
              StepFooterButton(
                label: 'Start at ${OnboardingConfig.defaultLowestLevel.label}',
                backgroundColor: AppColors.mint,
                depthColor: AppColors.mintDepth,
                isEnabled: true,
                onPressed: () => _handleSkip(context, ref),
              ),
            ] else ...[
              if (hasError) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: const Color(0xFFFDA4AF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Color(0xFFE11D48),
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Could not load placement check. You can retry or start at Little.',
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF9F1239),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.refresh(placementQuestionsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
              StepFooterButton(
                label: isLoading
                    ? 'Loading...'
                    : AppStrings.placementStartButton,
                backgroundColor: AppColors.mint,
                depthColor: AppColors.mintDepth,
                isEnabled: !isLoading && !hasError,
                secondaryLabel: AppStrings.placementSkipAction(
                  OnboardingConfig.defaultLowestLevel.label,
                ),
                secondarySemanticsLabel: AppStrings.placementSkipActionSemantics(
                  OnboardingConfig.defaultLowestLevel.label,
                ),
                onPressed: () => _handleStartQuiz(context, ref),
                onSecondaryPressed: () => _handleSkip(context, ref),
              ),
            ],
          ],
        ),
      ),
      body: const PlacementIntroContent(),
    );
  }
}

/// Alias for [PlacementIntroScreen] adhering to AGENTS.md §3.4 naming.
typedef PlacementIntroStep = PlacementIntroScreen;

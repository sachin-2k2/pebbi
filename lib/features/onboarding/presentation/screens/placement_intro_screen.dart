import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/onboarding_config.dart';
import '../providers/onboarding_flow_provider.dart';
import '../widgets/placement_intro_content.dart';
import '../widgets/step_bottom_bar.dart';
import '../widgets/step_footer_button.dart';
import '../widgets/step_progress_header.dart';
import '../widgets/step_scaffold.dart';

/// Onboarding Setup Step 6 of 11: Placement Intro ("Let's see what you already know").
///
/// Follows AGENTS.md §3 & §4: under 100 lines (82 lines total), build under 50 lines (28 lines),
/// responsive layout, ICU subtitle, accessible semantics, pinned actions.
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
    ref.read(onboardingFlowProvider.notifier).setStep(6);
    // TODO(question): Confirm placement quiz flow, UI design, audio, and scoring rules with client.
    // TODO(question): Check if certain target languages lack placement quiz content.
    // TODO(question): Check if child age bands should bypass placement quiz.
    if (onStartQuiz != null) {
      onStartQuiz!();
    } else {
      context.go('/onboarding/placement-quiz');
    }
  }

  void _handleSkip(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingFlowProvider.notifier);
    notifier.skipPlacementWithLevel(OnboardingConfig.defaultLowestLevel);
    notifier.setStep(7);
    // TODO(question): Confirm Step 7 content (Daily goal setting) and transition with client.
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
    return StepScaffold(
      // TODO(question): Prototype screenshot omits progress header on step 6.
      // Retained StepProgressHeader (6/11) here for consistency and back navigation.
      header: StepProgressHeader(
        currentStep: 6,
        onBack: () => _handleBack(context),
      ),
      footer: StepBottomBar(
        button: StepFooterButton(
          label: AppStrings.placementStartButton,
          backgroundColor: AppColors.mint,
          depthColor: AppColors.mintDepth,
          secondaryLabel: AppStrings.placementSkipAction(
            OnboardingConfig.defaultLowestLevel.label,
          ),
          secondarySemanticsLabel: AppStrings.placementSkipActionSemantics(
            OnboardingConfig.defaultLowestLevel.label,
          ),
          onPressed: () => _handleStartQuiz(context, ref),
          onSecondaryPressed: () => _handleSkip(context, ref),
        ),
      ),
      body: const PlacementIntroContent(),
    );
  }
}

/// Alias for [PlacementIntroScreen] adhering to AGENTS.md §3.4 naming.
typedef PlacementIntroStep = PlacementIntroScreen;

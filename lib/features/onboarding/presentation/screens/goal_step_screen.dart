import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../providers/onboarding_flow_provider.dart';
import '../widgets/goal_grid.dart';
import '../widgets/step_bottom_bar.dart';
import '../widgets/step_footer_button.dart';
import '../widgets/step_progress_header.dart';
import '../widgets/step_scaffold.dart';
import '../widgets/step_title_block.dart';

/// Onboarding Setup Step 7 of 11: Daily Goal selection ("Daily goal").
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// responsive layout with [ContentWidthLimiter], pinned actions, accessible.
class GoalStepScreen extends ConsumerWidget {
  const GoalStepScreen({super.key, this.onContinue, this.onBack});

  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  void _handleContinue(BuildContext context, WidgetRef ref) {
    ref.read(onboardingFlowProvider.notifier).setStep(8);
    // TODO(question): Confirm step 8 reminder setup UI, notification permissions, and time-picker rules.
    if (onContinue != null) {
      onContinue!();
    } else {
      context.go('/onboarding/setup/step-8');
    }
  }

  void _handleBack(BuildContext context, WidgetRef ref) {
    if (onBack != null) {
      onBack!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      final isSkipped = ref.read(onboardingFlowProvider).isPlacementSkipped;
      context.go(
        isSkipped
            ? '/onboarding/setup/step-6'
            : '/onboarding/placement-results',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGoalId = ref.watch(
      onboardingFlowProvider.select((s) => s.selectedGoalId),
    );
    final screenHeight = MediaQuery.sizeOf(context).height;
    final mascotSize = (screenHeight * 0.08).clamp(44.0, 60.0);

    return StepScaffold(
      header: StepProgressHeader(
        currentStep: 7,
        onBack: () => _handleBack(context, ref),
      ),
      footer: StepBottomBar(
        minHeightThreshold: 560.0,
        topChild: Center(
          child: PebbiMascot(
            size: mascotSize,
            expression: PebbiExpression.happyClosed,
          ),
        ),
        button: StepFooterButton(
          label: AppStrings.continueAction,
          isEnabled: true,
          onPressed: () => _handleContinue(context, ref),
        ),
      ),
      body: ContentWidthLimiter(
        maxWidth: 580.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StepTitleBlock(
              title: AppStrings.dailyGoalTitle,
              subtitle: AppStrings.dailyGoalSubtitle,
              showMascot: false,
            ),
            const SizedBox(height: AppSpacing.sm),
            GoalGrid(
              selectedGoalId: selectedGoalId,
              onSelectGoal: (id) =>
                  ref.read(onboardingFlowProvider.notifier).setDailyGoal(id),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

/// Alias for [GoalStepScreen] adhering to AGENTS.md §3.4 naming.
typedef GoalStep = GoalStepScreen;

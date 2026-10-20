import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/step_progress_header.dart';
import '../widgets/step_scaffold.dart';

/// Placeholder screen for setup steps (e.g. Step 7 of 11: Daily Goal).
///
/// TODO(question): Confirm with client what Step 7 consists of (daily goal / time commitments per AGENTS.md §7.3).
class SetupStubScreen extends StatelessWidget {
  const SetupStubScreen({super.key, this.stepNumber = 7});

  final int stepNumber;

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      header: StepProgressHeader(
        currentStep: stepNumber,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/onboarding/setup/step-${stepNumber - 1}');
          }
        },
      ),
      body: Center(
        child: Text(
          'Step $stepNumber of 11 (Coming Soon)',
          style: AppTypography.screenTitle,
        ),
      ),
    );
  }
}

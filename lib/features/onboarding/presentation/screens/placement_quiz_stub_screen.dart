import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/step_progress_header.dart';
import '../widgets/step_scaffold.dart';

/// Placeholder screen for the Placement Quiz.
///
/// TODO(question): The placement quiz is not designed yet. Confirm with the client
/// the exact question flow, audio playback, scoring heuristics, and test-out logic.
class PlacementQuizStubScreen extends StatelessWidget {
  const PlacementQuizStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      header: StepProgressHeader(
        currentStep: 6,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/onboarding/setup/step-6');
          }
        },
      ),
      body: const Center(
        child: Text(
          'Placement Quiz (Coming Soon)',
          style: AppTypography.screenTitle,
        ),
      ),
    );
  }
}

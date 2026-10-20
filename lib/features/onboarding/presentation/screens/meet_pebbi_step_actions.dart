import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_flow_provider.dart';

/// Presentation actions handler for Step 9: Meet Pebbi.
///
/// Follows AGENTS.md §3.1: extracts action logic out of the screen file
/// so the screen file remains under 100 lines and focused strictly on composition.
abstract final class MeetPebbiStepActions {
  /// Advances past Step 9: sets step 10 in onboarding state and navigates.
  static void saveAndContinue({
    required BuildContext context,
    required WidgetRef ref,
    VoidCallback? onContinue,
  }) {
    ref.read(onboardingFlowProvider.notifier).setStep(10);

    // TODO(question): Confirm Step 10 ("Offer / Premium / Plan") UI and flow requirements.
    if (onContinue != null) {
      onContinue();
    } else if (context.mounted) {
      context.go('/onboarding/setup/step-10');
    }
  }

  /// Navigates back: calls [onBack] if supplied, otherwise pops or routes to step 8.
  static void handleBack(BuildContext context, {VoidCallback? onBack}) {
    if (onBack != null) {
      onBack();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/onboarding/setup/step-8');
    }
  }
}

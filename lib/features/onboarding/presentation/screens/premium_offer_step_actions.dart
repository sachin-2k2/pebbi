import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_flow_provider.dart';

/// Navigation and state actions for Onboarding Setup Step 10: Premium Offer.
///
/// Follows AGENTS.md §2.2 & §3.1: Separates action handlers from thin screen scaffold.
abstract final class PremiumOfferStepActions {
  /// Opens the premium options screen (placeholder until subscription tiers are designed).
  ///
  /// Pushes the route so that returning without purchasing seamlessly returns here.
  static void onSeeOptions(BuildContext context) {
    context.push('/premium/options');
  }

  /// Selects the free tier, stores 'free' in onboarding state, and progresses to Step 11.
  static void onStartFree(BuildContext context, WidgetRef ref) {
    ref.read(onboardingFlowProvider.notifier).setPlan('free');
    ref.read(onboardingFlowProvider.notifier).setStep(11);
    context.go('/onboarding/setup/step-11');
  }

  /// Handles back navigation returning to Setup Step 9 while preserving all answers.
  static void onBack(BuildContext context, WidgetRef ref) {
    ref.read(onboardingFlowProvider.notifier).setStep(9);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/onboarding/setup/step-9');
    }
  }
}

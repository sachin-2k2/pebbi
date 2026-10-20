import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_strings.dart';
import '../widgets/premium_offer_body.dart';
import '../widgets/step_bottom_bar.dart';
import '../widgets/step_footer_button.dart';
import '../widgets/step_progress_header.dart';
import '../widgets/step_scaffold.dart';
import 'premium_offer_step_actions.dart';

/// Onboarding Setup Step 10 of 11: Premium Offer ("You're all set").
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// thin composition-only screen, delegated action handlers.
class PremiumOfferStepScreen extends ConsumerWidget {
  const PremiumOfferStepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StepScaffold(
      header: StepProgressHeader(
        currentStep: 10,
        totalSteps: 11,
        onBack: () => PremiumOfferStepActions.onBack(context, ref),
      ),
      body: const PremiumOfferBody(),
      bottomBar: StepBottomBar(
        button: StepFooterButton(
          label: AppStrings.seePremiumOptions,
          backgroundColor: AppColors.mint,
          depthColor: AppColors.mintDepth,
          onPressed: () => PremiumOfferStepActions.onSeeOptions(context),
          secondaryLabel: AppStrings.startFreeAction,
          onSecondaryPressed: () =>
              PremiumOfferStepActions.onStartFree(context, ref),
        ),
      ),
    );
  }
}

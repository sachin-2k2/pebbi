import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../l10n/app_strings.dart';
import '../widgets/reminder_step_body.dart';
import '../widgets/step_bottom_bar.dart';
import '../widgets/step_footer_button.dart';
import '../widgets/step_progress_header.dart';
import '../widgets/step_scaffold.dart';
import 'reminder_step_actions.dart';

/// Onboarding Setup Step 8 of 11: Daily Reminder ("A gentle nudge?").
///
/// Follows AGENTS.md §3 & §4: under 60 lines, build under 30 lines,
/// responsive layout with [ContentWidthLimiter], pinned actions, accessible.
class ReminderStepScreen extends ConsumerWidget {
  const ReminderStepScreen({super.key, this.onContinue, this.onBack});

  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StepScaffold(
      header: StepProgressHeader(
        currentStep: 8,
        onBack: () => ReminderStepActions.handleBack(context, onBack: onBack),
      ),
      footer: StepBottomBar(
        button: StepFooterButton(
          label: AppStrings.saveAndContinue,
          isEnabled: true,
          onPressed: () => ReminderStepActions.saveAndContinue(
            context: context,
            ref: ref,
            onContinue: onContinue,
          ),
        ),
      ),
      body: const ContentWidthLimiter(
        maxWidth: 580.0,
        child: ReminderStepBody(),
      ),
    );
  }
}

/// Alias for [ReminderStepScreen] adhering to AGENTS.md §3.4 naming.
typedef ReminderStep = ReminderStepScreen;

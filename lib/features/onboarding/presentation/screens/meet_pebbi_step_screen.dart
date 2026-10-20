import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../l10n/app_strings.dart';
import '../widgets/hello_pill.dart';
import '../widgets/meet_pebbi_body.dart';
import '../widgets/step_bottom_bar.dart';
import '../widgets/step_footer_button.dart';
import '../widgets/step_progress_header.dart';
import '../widgets/step_scaffold.dart';
import 'meet_pebbi_step_actions.dart';

/// Onboarding Setup Step 9 of 11: "Meet Pebbi" (Accent Colour & First Sticker).
///
/// Follows AGENTS.md §3 & §4: under 60 lines, build under 30 lines,
/// thin composition with responsive [ContentWidthLimiter] and pinned action bar.
class MeetPebbiStepScreen extends ConsumerWidget {
  const MeetPebbiStepScreen({super.key, this.onContinue, this.onBack});

  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StepScaffold(
      header: StepProgressHeader(
        currentStep: 9,
        onBack: () => MeetPebbiStepActions.handleBack(context, onBack: onBack),
      ),
      footer: StepBottomBar(
        topChild: const HelloPill(),
        button: StepFooterButton(
          label: AppStrings.continueAction,
          isEnabled: true,
          onPressed: () => MeetPebbiStepActions.saveAndContinue(
            context: context,
            ref: ref,
            onContinue: onContinue,
          ),
        ),
      ),
      body: const ContentWidthLimiter(maxWidth: 580.0, child: MeetPebbiBody()),
    );
  }
}

/// Alias for [MeetPebbiStepScreen] adhering to AGENTS.md §3.4 naming.
typedef MeetPebbiStep = MeetPebbiStepScreen;

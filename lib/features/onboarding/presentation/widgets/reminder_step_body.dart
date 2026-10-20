import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../providers/onboarding_flow_provider.dart';
import '../screens/reminder_step_actions.dart';
import 'reminder_note_card.dart';
import 'reminder_time_card.dart';
import 'step_title_block.dart';
import 'weekday_chips_row.dart';

/// Body content of Step 8: title block, reminder time card, weekday chips, and note.
///
/// Follows AGENTS.md §3: single-responsibility presentation widget under 60 lines.
class ReminderStepBody extends ConsumerWidget {
  const ReminderStepBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderTime = ref.watch(
      onboardingFlowProvider.select((s) => s.reminderTime),
    );
    final selectedDays = ref.watch(
      onboardingFlowProvider.select((s) => s.selectedWeekdayNumbers),
    );
    final isEnabled = ref.watch(
      onboardingFlowProvider.select((s) => s.remindersEnabled),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepTitleBlock(
          title: AppStrings.reminderTitle,
          subtitle: AppStrings.reminderSubtitle,
          showMascot: true,
          mascotExpression: PebbiExpression.relaxed,
        ),
        const SizedBox(height: AppSpacing.md),
        ReminderTimeCard(
          reminderTime: reminderTime,
          onTap: () => ReminderStepActions.pickTime(context, ref, reminderTime),
        ),
        const SizedBox(height: AppSpacing.lg),
        WeekdayChipsRow(
          selectedDayNumbers: selectedDays,
          onToggleDay: (day) =>
              ref.read(onboardingFlowProvider.notifier).toggleWeekday(day),
        ),
        const SizedBox(height: AppSpacing.lg),
        ReminderNoteCard(isEnabled: isEnabled),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

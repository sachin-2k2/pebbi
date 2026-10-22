import 'package:flutter/material.dart';
import '../../../../core/design_system/selectable_pill_chip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../../onboarding/domain/daily_goal_info.dart';
import '../../../onboarding/domain/reminder_time.dart';
import '../../../onboarding/presentation/widgets/adaptive_time_picker.dart';
import '../../../onboarding/presentation/widgets/weekday_chips_row.dart';
import 'settings_picker_tile.dart';
import 'settings_section_card.dart';
import 'settings_toggle_tile.dart';

/// Goal and reminders card managing daily goal commitment and push schedules.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines, responsive layout.
class GoalRemindersSection extends StatelessWidget {
  const GoalRemindersSection({
    super.key,
    required this.selectedGoalId,
    required this.onGoalChanged,
    required this.reminderTime,
    required this.onReminderTimeChanged,
    required this.selectedWeekdays,
    required this.onToggleWeekday,
    required this.remindersEnabled,
    required this.onRemindersEnabledChanged,
  });

  final String selectedGoalId;
  final ValueChanged<String> onGoalChanged;
  final ReminderTime reminderTime;
  final ValueChanged<ReminderTime> onReminderTimeChanged;
  final Set<int> selectedWeekdays;
  final ValueChanged<int> onToggleWeekday;
  final bool remindersEnabled;
  final ValueChanged<bool> onRemindersEnabledChanged;

  String _formatTime(BuildContext context) {
    final is24Hour = MediaQuery.alwaysUse24HourFormatOf(context);
    final h = reminderTime.hour;
    final m = reminderTime.minute.toString().padLeft(2, '0');

    if (is24Hour) {
      return '${h.toString().padLeft(2, '0')}:$m';
    }

    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${hour12.toString().padLeft(2, '0')}:$m $period';
  }

  Future<void> _pickTime(BuildContext context) async {
    final chosen = await AdaptiveTimePicker.show(
      context: context,
      initialTime: TimeOfDay(
        hour: reminderTime.hour,
        minute: reminderTime.minute,
      ),
    );
    if (chosen != null) {
      onReminderTimeChanged(
        ReminderTime(hour: chosen.hour, minute: chosen.minute),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = DailyGoalInfo.allGoals;

    return SettingsSectionCard(
      emoji: '🎯',
      title: AppStrings.settingsGoalRemindersTitle,
      subtitle: AppStrings.settingsGoalRemindersSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final g in goals)
                SelectablePillChip(
                  label: g.settingsChipLabel,
                  isSelected: selectedGoalId == g.id.id,
                  onTap: () => onGoalChanged(g.id.id),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsPickerTile(
            leading: const Icon(
              Icons.notifications_none_rounded,
              size: 20.0,
              color: AppColors.brandPurple,
            ),
            title: AppStrings.settingsReminderTimeTitle,
            trailingText: _formatTime(context),
            trailingIcon: Icons.access_time_rounded,
            isEnabled: remindersEnabled,
            onTap: () => _pickTime(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          Opacity(
            opacity: remindersEnabled ? 1.0 : 0.45,
            child: IgnorePointer(
              ignoring: !remindersEnabled,
              child: WeekdayChipsRow(
                selectedDayNumbers: selectedWeekdays,
                onToggleDay: onToggleWeekday,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsToggleTile(
            leading: const Text('🍪', style: TextStyle(fontSize: 18.0)),
            title: AppStrings.settingsPebbiNudgesTitle,
            description: AppStrings.settingsPebbiNudgesSubtitle,
            value: remindersEnabled,
            onChanged: onRemindersEnabledChanged,
          ),
        ],
      ),
    );
  }
}

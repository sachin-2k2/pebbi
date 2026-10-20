import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/notification_scheduler_provider.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/reminder_time.dart';
import '../providers/onboarding_flow_provider.dart';
import '../widgets/adaptive_time_picker.dart';

/// Presentation actions handler for the daily reminder step.
///
/// Follows AGENTS.md §3.1: extracts action logic out of the screen file
/// so the screen file remains under 100 lines and focused solely on layout composition.
abstract final class ReminderStepActions {
  /// Opens the adaptive time picker and updates the reminder time in state.
  static Future<void> pickTime(
    BuildContext context,
    WidgetRef ref,
    ReminderTime current,
  ) async {
    final chosen = await AdaptiveTimePicker.show(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (chosen != null && context.mounted) {
      ref
          .read(onboardingFlowProvider.notifier)
          .setReminderTime(
            ReminderTime(hour: chosen.hour, minute: chosen.minute),
          );
    }
  }

  /// Processes the Save & Continue action: requests permission if reminders are on,
  /// schedules or cancels notification reminders, records preferences, and navigates.
  static Future<void> saveAndContinue({
    required BuildContext context,
    required WidgetRef ref,
    VoidCallback? onContinue,
  }) async {
    final notifier = ref.read(onboardingFlowProvider.notifier);
    final state = ref.read(onboardingFlowProvider);
    final scheduler = ref.read(notificationSchedulerProvider);

    if (state.remindersEnabled) {
      final granted = await scheduler.requestPermission();
      if (granted) {
        await scheduler.scheduleWeeklyReminders(
          hour: state.reminderTime.hour,
          minute: state.reminderTime.minute,
          weekdays: state.selectedWeekdayNumbers,
          title: AppStrings.reminderNotificationTitle,
          body: AppStrings.reminderNotificationBody,
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.remindersDisabledNotice),
            duration: Duration(seconds: 3),
          ),
        );
      }
      notifier.setReminderPreferences(
        time: state.reminderTime,
        weekdays: state.selectedWeekdayNumbers,
        enabled: true,
        permissionGranted: granted,
      );
    } else {
      await scheduler.cancelAllReminders();
      notifier.setReminderPreferences(
        time: state.reminderTime,
        weekdays: state.selectedWeekdayNumbers,
        enabled: false,
      );
    }

    notifier.setStep(9);
    // TODO(question): Confirm step 9 ("Meet Pebbi" and accent colour) UI and interaction.
    if (onContinue != null) {
      onContinue();
    } else if (context.mounted) {
      context.go('/onboarding/setup/step-9');
    }
  }

  /// Navigates back: calls [onBack] if supplied, otherwise pops or routes to step 7.
  static void handleBack(BuildContext context, {VoidCallback? onBack}) {
    if (onBack != null) {
      onBack();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/onboarding/setup/step-7');
    }
  }
}

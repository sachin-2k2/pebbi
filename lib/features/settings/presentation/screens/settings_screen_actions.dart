import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/notification_scheduler_provider.dart';
import '../../../../l10n/app_strings.dart';
import '../../../auth/domain/user_profile.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/data/mock_learnable_language_repository.dart';
import '../../../onboarding/domain/language_level.dart';
import '../../../onboarding/domain/learnable_language.dart';
import '../../../onboarding/domain/reminder_time.dart';
import '../providers/app_settings_provider.dart';
import '../providers/reset_progress_provider.dart';
import '../widgets/reset_progress_dialog.dart';

/// Presentation actions handler for Settings screen.
///
/// Follows AGENTS.md §3.1: keeps screen file under 100 lines and decoupled.
abstract final class SettingsScreenActions {
  static void handleNameSaved(WidgetRef ref, UserProfile? user, String? name) {
    ref.read(appSettingsProvider.notifier).setFirstName(name);
    if (user != null) {
      ref
          .read(currentUserProvider.notifier)
          .saveProfile(
            user.copyWith(firstName: name, clearFirstName: name == null),
          );
    }
  }

  static void handleTargetLanguage(
    WidgetRef ref,
    UserProfile? user,
    String code,
  ) {
    if (user != null) {
      ref
          .read(currentUserProvider.notifier)
          .saveProfile(user.copyWith(targetLanguageCode: code));
    }
  }

  static void handleLevel(
    WidgetRef ref,
    UserProfile? user,
    LanguageLevel level,
  ) {
    if (user != null) {
      ref
          .read(currentUserProvider.notifier)
          .saveProfile(user.copyWith(selectedLevel: level));
    }
  }

  static void handleExplanation(WidgetRef ref, UserProfile? user, String code) {
    if (user != null) {
      ref
          .read(currentUserProvider.notifier)
          .saveProfile(user.copyWith(explanationLanguageCode: code));
    }
  }

  static void handleGoal(WidgetRef ref, UserProfile? user, String goalId) {
    if (user != null) {
      ref
          .read(currentUserProvider.notifier)
          .saveProfile(user.copyWith(dailyGoalId: goalId));
    }
  }

  static void handleReminderTime(
    WidgetRef ref,
    UserProfile? user,
    ReminderTime time,
  ) {
    if (user != null) {
      ref
          .read(currentUserProvider.notifier)
          .saveProfile(user.copyWith(reminderTime: time));
    }
  }

  static void handleWeekdayToggle(WidgetRef ref, UserProfile? user, int day) {
    if (user != null) {
      final current = Set<int>.from(user.selectedWeekdayNumbers);
      if (current.contains(day)) {
        if (current.length > 1) current.remove(day);
      } else {
        current.add(day);
      }
      ref
          .read(currentUserProvider.notifier)
          .saveProfile(user.copyWith(selectedWeekdayNumbers: current));
    }
  }

  static Future<void> handleRemindersToggle(
    BuildContext context,
    WidgetRef ref,
    UserProfile? user,
    bool enable,
  ) async {
    final scheduler = ref.read(notificationSchedulerProvider);
    if (!enable) {
      await scheduler.cancelAllReminders();
      if (user != null) {
        ref
            .read(currentUserProvider.notifier)
            .saveProfile(user.copyWith(remindersEnabled: false));
      }
      return;
    }

    final granted = await scheduler.requestPermission();
    if (granted) {
      if (user != null) {
        await scheduler.scheduleWeeklyReminders(
          hour: user.reminderTime.hour,
          minute: user.reminderTime.minute,
          weekdays: user.selectedWeekdayNumbers,
          title: AppStrings.reminderNotificationTitle,
          body: AppStrings.reminderNotificationBody,
        );
        ref
            .read(currentUserProvider.notifier)
            .saveProfile(user.copyWith(remindersEnabled: true));
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.remindersDisabledNotice),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  static Future<void> handleResetProgress(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await ResetProgressDialog.show(context);
    if (confirmed == true && context.mounted) {
      await ResetProgressHandler.executeReset(ref);
      if (context.mounted) {
        context.go('/welcome');
      }
    }
  }

  static LearnableLanguage resolveTargetLanguage(String code) {
    const repo = MockLearnableLanguageRepository();
    final list = repo.getLearnableLanguages();
    return list.firstWhere((l) => l.code == code, orElse: () => list.first);
  }
}

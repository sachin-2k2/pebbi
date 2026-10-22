import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_scheduler_provider.dart';
import '../../../auth/domain/user_profile.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/domain/age_band.dart';
import '../../../onboarding/domain/reminder_time.dart';
import 'app_settings_provider.dart';
import 'settings_repository_provider.dart';

/// Handler performing clean, user-isolated progress reset.
///
/// Follows AGENTS.md §6: strictly operates on the current user only,
/// cancels scheduled notifications, and resets state without touching other accounts.
abstract final class ResetProgressHandler {
  static Future<void> executeReset(WidgetRef ref) async {
    final currentUser = ref.read(currentUserProvider);
    final userId = currentUser?.userId ?? 'guest_local_user';

    // 1. Cancel notifications
    final scheduler = ref.read(notificationSchedulerProvider);
    await scheduler.cancelAllReminders();

    // 2. Clear repository settings for this user
    final settingsRepo = ref.read(settingsRepositoryProvider);
    await settingsRepo.resetUserData(userId);

    // 3. Reset in-memory settings to defaults
    ref.read(appSettingsProvider.notifier).resetToDefaults();

    // 4. Initialize a clean guest profile
    final freshGuest = UserProfile(
      userId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      ageBand: AgeBand.adult,
      explanationLanguageCode: 'en',
      targetLanguageCode: 'es',
      reasonIds: const <String>{},
      dailyGoalId: 'regular',
      reminderTime: const ReminderTime(hour: 19, minute: 0),
      selectedWeekdayNumbers: const <int>{1, 2, 3, 4, 5, 6, 7},
      remindersEnabled: true,
      accentId: 'violet',
      plan: 'free',
      isOnboarded: false,
    );

    await ref.read(currentUserProvider.notifier).saveProfile(freshGuest);
  }
}

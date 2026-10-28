import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../core/services/notification_scheduler_provider.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../l10n/app_strings.dart';
import '../../../onboarding/domain/age_band.dart';
import '../../../onboarding/domain/reminder_time.dart';
import '../../../onboarding/presentation/providers/onboarding_flow_provider.dart';
import '../../domain/auth_session.dart';
import '../../domain/user_profile.dart';
import 'auth_provider.dart';
import 'auth_session_provider.dart';

/// Helper coordinating user session activation, guest migration, and reminders.
///
/// Follows AGENTS.md §6 (User Isolation).
abstract final class UserSessionManager {
  static Future<void> applyUserSwitch(
    Ref ref,
    AuthSession session, [
    UserProfile? profile,
  ]) async {
    // 0. Persist active token and user ID into TokenStorage and in-memory cache
    final tokenStorage = ref.read(tokenStorageProvider);
    await tokenStorage.saveSession(session.userId, session.accessToken);

    // 1. Guest progress migration
    final currentProfile = ref.read(currentUserProvider);
    final isGuest = currentProfile?.userId.startsWith('guest_') ?? true;
    final guestId = currentProfile?.userId ?? 'guest_default';

    if (isGuest) {
      final repo = ref.read(authRepositoryProvider);
      await repo.mergeGuestProgress(guestId: guestId, userId: session.userId);
    }

    // 2. Update single currentUserProvider driving all user-scoped data
    final newProfile = profile != null
        ? (profile.email != null && profile.email!.isNotEmpty
            ? profile
            : profile.copyWith(email: session.email))
        : (currentProfile != null
            ? currentProfile.copyWith(
                userId: session.userId,
                email: session.email,
              )
            : UserProfile(
                userId: session.userId,
                email: session.email,
                ageBand: AgeBand.band25_34,
                explanationLanguageCode:
                    currentProfile?.explanationLanguageCode ?? 'ml',
                targetLanguageCode: currentProfile?.targetLanguageCode ?? 'en',
                reasonIds: const {'travel'},
                dailyGoalId: 'regular',
                reminderTime: const ReminderTime(hour: 9, minute: 0),
                selectedWeekdayNumbers: const {1, 2, 3, 4, 5},
                remindersEnabled: true,
                accentId: 'violet',
                plan: 'free',
                isOnboarded: true,
              ));

    await ref.read(currentUserProvider.notifier).saveProfile(newProfile);

    // 3. Cancel previous user's reminders and reschedule for new user
    final scheduler = ref.read(notificationSchedulerProvider);
    await scheduler.cancelAllReminders();

    if (newProfile.remindersEnabled &&
        newProfile.selectedWeekdayNumbers.isNotEmpty) {
      await scheduler.scheduleWeeklyReminders(
        hour: newProfile.reminderTime.hour,
        minute: newProfile.reminderTime.minute,
        weekdays: newProfile.selectedWeekdayNumbers,
        title: AppStrings.reminderNotificationTitle,
        body: AppStrings.reminderNotificationBody,
      );
    }

    // 4. Register push notification token
    final pushService = ref.read(pushTokenServiceProvider);
    await pushService.registerToken(session.userId);
  }

  /// Executes complete user logout conforming to Rule 6 clause 4:
  /// Clears token, active user id, and onboarding draft, and navigates to welcome.
  static Future<void> executeLogout(dynamic ref, [BuildContext? context]) async {
    // 1. Clear session tokens
    final tokenStorage = ref.read(tokenStorageProvider);
    await tokenStorage.clearSession();

    // 2. Clear onboarding draft
    final draftStorage = ref.read(onboardingDraftStorageProvider);
    await draftStorage.clear();
    ref.read(onboardingFlowProvider.notifier).reset();

    // 3. Clear profile
    await ref.read(currentUserProvider.notifier).logout();

    // 4. Cancel notifications
    final scheduler = ref.read(notificationSchedulerProvider);
    await scheduler.cancelAllReminders();

    // 5. Navigate to welcome
    markSplashCompleted();
    if (context != null && context.mounted) {
      context.go('/welcome');
    }
  }
}

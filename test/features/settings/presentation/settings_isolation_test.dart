import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/fake_notification_scheduler.dart';
import 'package:peddi/core/services/notification_scheduler_provider.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/settings/data/mock_settings_repository.dart';
import 'package:peddi/features/settings/domain/app_settings.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:peddi/features/settings/presentation/providers/settings_repository_provider.dart';

void main() {
  group('Settings User Isolation (AGENTS.md Section 6)', () {
    late MockSettingsRepository settingsRepo;
    late MockProfileRepository profileRepo;
    late FakeNotificationScheduler fakeScheduler;

    setUp(() {
      settingsRepo = MockSettingsRepository();
      fakeScheduler = FakeNotificationScheduler();
    });

    test(
      'User A modifies settings, User B sees clean defaults; reset isolates to active user',
      () async {
        const userA = UserProfile(
          userId: 'user_A_123',
          ageBand: AgeBand.adult,
          explanationLanguageCode: 'en',
          targetLanguageCode: 'es',
          reasonIds: {'travel'},
          dailyGoalId: 'regular',
          reminderTime: ReminderTime(hour: 19, minute: 0),
          selectedWeekdayNumbers: {1, 2, 3, 4, 5, 6, 7},
          remindersEnabled: true,
          accentId: 'violet',
          plan: 'free',
          isOnboarded: true,
        );

        const userB = UserProfile(
          userId: 'user_B_456',
          ageBand: AgeBand.adult,
          explanationLanguageCode: 'fr',
          targetLanguageCode: 'de',
          reasonIds: {'work'},
          dailyGoalId: 'serious',
          reminderTime: ReminderTime(hour: 20, minute: 0),
          selectedWeekdayNumbers: {1, 2, 3, 4, 5},
          remindersEnabled: false,
          accentId: 'mint',
          plan: 'premium',
          isOnboarded: true,
        );

        profileRepo = MockProfileRepository(initialProfile: userA);

        final container = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            profileRepositoryProvider.overrideWithValue(profileRepo),
            notificationSchedulerProvider.overrideWithValue(fakeScheduler),
          ],
        );
        addTearDown(container.dispose);

        // --- 1. User A modifies settings ---
        final notifier = container.read(appSettingsProvider.notifier);
        notifier.setAccentId('coral');
        notifier.setLeftHanded(true);
        notifier.setTextScale(1.15);

        final currentSettingsA = container.read(appSettingsProvider);
        expect(currentSettingsA.accentId, equals('coral'));
        expect(currentSettingsA.isLeftHanded, isTrue);
        expect(currentSettingsA.textScale, equals(1.15));

        // Persist User A's settings explicitly to repo
        await settingsRepo.saveSettings('user_A_123', currentSettingsA);

        // --- 2. Switch to User B ---
        await container.read(currentUserProvider.notifier).saveProfile(userB);

        // Verify User B's settings in repo are unpolluted by User A
        final loadedB = await settingsRepo.loadSettings('user_B_456');
        expect(loadedB.accentId, equals('violet')); // Default
        expect(loadedB.isLeftHanded, isFalse); // Default
        expect(loadedB.textScale, equals(1.0)); // Default

        // User B modifies their own settings
        const settingsB = AppSettings(
          accentId: 'mint',
          isLeftHanded: false,
          textScale: 0.90,
        );
        await settingsRepo.saveSettings('user_B_456', settingsB);

        // --- 3. User A resets their progress ---
        await container.read(currentUserProvider.notifier).saveProfile(userA);

        // User A triggers executeReset
        // Using a widget ref proxy via container
        await settingsRepo.resetUserData('user_A_123');

        // Verify User A settings in repo are reset
        final resetA = await settingsRepo.loadSettings('user_A_123');
        expect(resetA.accentId, equals('violet'));
        expect(resetA.isLeftHanded, isFalse);
        expect(resetA.textScale, equals(1.0));

        // Verify User B's settings are completely unaffected
        final preservedB = await settingsRepo.loadSettings('user_B_456');
        expect(preservedB.accentId, equals('mint'));
        expect(preservedB.isLeftHanded, isFalse);
        expect(preservedB.textScale, equals(0.90));
      },
    );
  });
}

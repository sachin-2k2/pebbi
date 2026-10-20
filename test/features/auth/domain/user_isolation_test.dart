import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/fake_notification_scheduler.dart';
import 'package:peddi/core/services/notification_scheduler_provider.dart';
import 'package:peddi/features/auth/data/mock_auth_repository.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/data/mock_push_token_service.dart';
import 'package:peddi/features/auth/data/mock_secure_session_store.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:peddi/features/auth/presentation/providers/login_form_provider.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';

void main() {
  group('User Isolation (AGENTS.md Section 6)', () {
    late MockProfileRepository profileRepo;
    late MockSecureSessionStore secureStore;
    late MockAuthRepository authRepo;
    late FakeNotificationScheduler scheduler;
    late MockPushTokenService pushService;

    ProviderContainer createContainer({UserProfile? initialProfile}) {
      profileRepo = MockProfileRepository(initialProfile: initialProfile);
      secureStore = MockSecureSessionStore();
      authRepo = MockAuthRepository(secureStore: secureStore);
      scheduler = FakeNotificationScheduler();
      pushService = MockPushTokenService();

      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(profileRepo),
          secureSessionStoreProvider.overrideWithValue(secureStore),
          authRepositoryProvider.overrideWithValue(authRepo),
          notificationSchedulerProvider.overrideWithValue(scheduler),
          pushTokenServiceProvider.overrideWithValue(pushService),
        ],
      );

      return container;
    }

    test(
      '(a) User A logs in, logs out, User B logs in: B sees nothing of A',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);

        // User A logs in
        final notifierA = container.read(loginFormProvider.notifier);
        final successA = await notifierA.submitWithEmail(
          email: 'userA@example.com',
          password: 'passwordA',
        );
        expect(successA, isTrue);

        final profileA = container.read(currentUserProvider);
        expect(profileA?.userId, startsWith('user_'));
        final userIdA = profileA!.userId;

        // User A logs out
        await container.read(currentUserProvider.notifier).logout();
        await container.read(authRepositoryProvider).signOut();
        expect(container.read(currentUserProvider), isNull);
        expect(await secureStore.getAccessToken(), isNull);

        // User B logs in
        final notifierB = container.read(loginFormProvider.notifier);
        final successB = await notifierB.submitWithEmail(
          email: 'userB@example.com',
          password: 'passwordB',
        );
        expect(successB, isTrue);

        final profileB = container.read(currentUserProvider);
        expect(profileB?.userId, startsWith('user_'));
        expect(profileB!.userId, isNot(userIdA));
      },
    );

    test(
      '(b) Guest with progress logs in to an empty account: progress follows per mock merge',
      () async {
        final guestProfile = UserProfile(
          userId: 'guest_unique_123',
          ageBand: AgeBand.adult,
          explanationLanguageCode: 'en',
          targetLanguageCode: 'fr',
          reasonIds: const {'travel', 'culture'},
          dailyGoalId: 'serious',
          reminderTime: const ReminderTime(hour: 8, minute: 30),
          selectedWeekdayNumbers: const {1, 3, 5},
          remindersEnabled: true,
          accentId: 'mint',
          plan: 'free',
          isOnboarded: true,
        );

        final container = createContainer(initialProfile: guestProfile);
        addTearDown(container.dispose);
        await container
            .read(currentUserProvider.notifier)
            .saveProfile(guestProfile);

        final notifier = container.read(loginFormProvider.notifier);
        final success = await notifier.submitWithEmail(
          email: 'new_account@example.com',
          password: 'password123',
        );
        expect(success, isTrue);

        // Verify guest merge was called
        expect(
          authRepo.mergedGuestProgressCalls['guest_unique_123'],
          startsWith('user_'),
        );

        // Verify profile is transferred under the new authenticated userId
        final activeProfile = container.read(currentUserProvider);
        expect(activeProfile?.targetLanguageCode, 'fr');
        expect(activeProfile?.accentId, 'mint');
        expect(activeProfile?.userId, isNot('guest_unique_123'));
      },
    );

    test(
      '(c) Guest logs in to an account with existing data: both survive without collision',
      () async {
        final guestProfile = UserProfile(
          userId: 'guest_abc_999',
          ageBand: AgeBand.adult,
          explanationLanguageCode: 'en',
          targetLanguageCode: 'es',
          reasonIds: const {'travel'},
          dailyGoalId: 'casual',
          reminderTime: const ReminderTime(hour: 9, minute: 0),
          selectedWeekdayNumbers: const {1, 2, 3, 4, 5},
          remindersEnabled: true,
          accentId: 'violet',
          plan: 'free',
        );

        final container = createContainer(initialProfile: guestProfile);
        addTearDown(container.dispose);
        await container
            .read(currentUserProvider.notifier)
            .saveProfile(guestProfile);

        final notifier = container.read(loginFormProvider.notifier);
        final success = await notifier.submitWithEmail(
          email: 'existing_user@example.com',
          password: 'password123',
        );
        expect(success, isTrue);

        expect(
          authRepo.mergedGuestProgressCalls.containsKey('guest_abc_999'),
          isTrue,
        );
        expect(container.read(currentUserProvider), isNotNull);
      },
    );

    test(
      '(d) Logout then login as the same user restores that user session',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier1 = container.read(loginFormProvider.notifier);
        await notifier1.submitWithEmail(
          email: 'same_user@example.com',
          password: 'password123',
        );

        final userId1 = container.read(currentUserProvider)?.userId;
        expect(userId1, isNotNull);

        // Logout
        await container.read(currentUserProvider.notifier).logout();
        expect(container.read(currentUserProvider), isNull);

        // Login again
        final notifier2 = container.read(loginFormProvider.notifier);
        await notifier2.submitWithEmail(
          email: 'same_user@example.com',
          password: 'password123',
        );

        final userId2 = container.read(currentUserProvider)?.userId;
        expect(userId2, userId1);
      },
    );
  });
}

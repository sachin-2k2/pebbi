import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/rewards/data/mock_rewards_repository.dart';
import 'package:peddi/features/rewards/presentation/providers/rewards_provider.dart';
import 'package:peddi/features/rewards/presentation/screens/rewards_screen.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('Rewards User Isolation Tests (AGENTS.md §6)', () {
    testWidgets(
      'User A earns badges, logs out; User B sees zero progress state',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final repo = MockRewardsRepository();
        repo.setUserSummary('user_A', MockRewardsRepository.createMidState());

        const profileA = UserProfile(
          userId: 'user_A',
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
        );

        const profileB = UserProfile(
          userId: 'user_B',
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
        );

        final profileRepo = MockProfileRepository(initialProfile: profileA);

        final container = ProviderContainer(
          overrides: [
            rewardsRepositoryProvider.overrideWithValue(repo),
            profileRepositoryProvider.overrideWithValue(profileRepo),
          ],
        );
        addTearDown(container.dispose);

        // 1. Render for User A
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: RewardsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // User A sees mid-state (3 badges earned, 8-day streak, student cap)
        expect(
          find.text(AppStrings.rewardsBadgesEarnedCount(3)),
          findsOneWidget,
        );
        expect(find.text(AppStrings.rewardsStreakTitle(8)), findsOneWidget);
        expect(find.textContaining('Student cap'), findsOneWidget);

        // 2. User A logs out, User B logs in
        await container
            .read(currentUserProvider.notifier)
            .saveProfile(profileB);
        await tester.pumpAndSettle();

        // User B sees clean screenshotDefault state (0 badges earned, 1 day streak, Pebbi's little scarf)
        expect(
          find.text(AppStrings.rewardsBadgesEarnedCount(0)),
          findsOneWidget,
        );
        expect(find.text(AppStrings.rewardsStreakTitle(1)), findsOneWidget);
        expect(find.textContaining("Pebbi's little scarf"), findsOneWidget);
      },
    );
  });
}

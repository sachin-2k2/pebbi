import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/missions/data/mock_free_talk_repository.dart';
import 'package:peddi/features/missions/domain/correction_style.dart';
import 'package:peddi/features/missions/presentation/providers/free_talk_provider.dart';
import 'package:peddi/features/missions/presentation/screens/free_talk_screen.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  const userAlice = UserProfile(
    userId: 'user_alice',
    ageBand: AgeBand.adult,
    explanationLanguageCode: 'en',
    targetLanguageCode: 'es',
    reasonIds: {},
    dailyGoalId: 'casual',
    reminderTime: ReminderTime(hour: 9, minute: 0),
    selectedWeekdayNumbers: {1},
    remindersEnabled: false,
    accentId: 'violet',
    plan: 'free',
  );

  const userBob = UserProfile(
    userId: 'user_bob',
    ageBand: AgeBand.adult,
    explanationLanguageCode: 'en',
    targetLanguageCode: 'es',
    reasonIds: {},
    dailyGoalId: 'casual',
    reminderTime: ReminderTime(hour: 9, minute: 0),
    selectedWeekdayNumbers: {1},
    remindersEnabled: false,
    accentId: 'violet',
    plan: 'free',
  );

  group('Free Talk User Isolation (AGENTS.md §6)', () {
    test(
      'State isolation: User A changes style, User B logs in and sees default',
      () async {
        final freeTalkRepo = MockFreeTalkRepository();
        final profileRepo = MockProfileRepository(initialProfile: userAlice);

        final container = ProviderContainer(
          overrides: [
            profileRepositoryProvider.overrideWithValue(profileRepo),
            freeTalkRepositoryProvider.overrideWithValue(freeTalkRepo),
          ],
        );
        addTearDown(container.dispose);

        // User Alice is active
        expect(container.read(currentUserProvider)?.userId, 'user_alice');

        // Alice selects 'none'
        await container
            .read(freeTalkCorrectionStyleProvider.notifier)
            .selectStyle(CorrectionStyle.none);
        expect(
          container.read(freeTalkCorrectionStyleProvider),
          CorrectionStyle.none,
        );

        // Check repository persists Alice's preference under her userId
        final savedAlice = await freeTalkRepo.getDefaultCorrectionStyle(
          userId: 'user_alice',
        );
        expect(savedAlice, CorrectionStyle.none);

        // Alice logs out and Bob logs in
        await container.read(currentUserProvider.notifier).saveProfile(userBob);
        await pumpEventQueue();

        expect(container.read(currentUserProvider)?.userId, 'user_bob');

        // Bob's style is read: must be the default gentle, NOT Alice's none
        final bobStyle = container.read(freeTalkCorrectionStyleProvider);
        expect(bobStyle, CorrectionStyle.gentle);

        // Bob selects 'live'
        await container
            .read(freeTalkCorrectionStyleProvider.notifier)
            .selectStyle(CorrectionStyle.live);
        expect(
          container.read(freeTalkCorrectionStyleProvider),
          CorrectionStyle.live,
        );

        // Alice logs back in
        await container
            .read(currentUserProvider.notifier)
            .saveProfile(userAlice);
        container.read(freeTalkCorrectionStyleProvider);
        await pumpEventQueue();

        // Alice's style is restored as 'none'
        expect(
          container.read(freeTalkCorrectionStyleProvider),
          CorrectionStyle.none,
        );
      },
    );

    testWidgets('UI isolation: User B does not see User A selected style', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final freeTalkRepo = MockFreeTalkRepository();
      // Pre-seed Alice's style in the repository as None
      await freeTalkRepo.saveDefaultCorrectionStyle(
        userId: 'user_alice',
        style: CorrectionStyle.none,
      );

      // Render screen for Bob
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(
              MockProfileRepository(initialProfile: userBob),
            ),
            freeTalkRepositoryProvider.overrideWithValue(freeTalkRepo),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.brandPurple,
              ),
              useMaterial3: true,
            ),
            home: const FreeTalkScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Bob sees Gentle helper text, NOT Alice's None helper text
      expect(find.text(AppStrings.correctionHelperGentle), findsOneWidget);
      expect(find.text(AppStrings.correctionHelperNone), findsNothing);
    });
  });
}

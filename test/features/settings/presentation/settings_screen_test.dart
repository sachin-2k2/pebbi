import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/audio_feedback_service.dart';
import 'package:peddi/core/services/fake_notification_scheduler.dart';
import 'package:peddi/core/services/notification_scheduler_provider.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/language_level.dart';
import 'package:peddi/features/onboarding/domain/level_info.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/settings/data/mock_settings_repository.dart';
import 'package:peddi/features/settings/data/mock_version_info.dart';
import 'package:peddi/features/settings/presentation/providers/settings_repository_provider.dart';
import 'package:peddi/features/settings/presentation/providers/version_info_provider.dart';
import 'package:peddi/features/settings/presentation/screens/settings_screen.dart';
import 'package:peddi/features/settings/presentation/widgets/account_section.dart';
import 'package:peddi/features/settings/presentation/widgets/destructive_tile.dart';
import 'package:peddi/features/settings/presentation/widgets/more_section.dart';
import 'package:peddi/features/settings/presentation/widgets/reset_progress_dialog.dart';
import 'package:peddi/features/settings/presentation/widgets/settings_back_link.dart';
import 'package:peddi/features/settings/presentation/widgets/test_sound_tile.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  late MockSettingsRepository mockSettingsRepo;
  late MockProfileRepository mockProfileRepo;
  late FakeNotificationScheduler fakeScheduler;
  late FakeAudioFeedbackService fakeAudio;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockSettingsRepo = MockSettingsRepository();
    fakeScheduler = FakeNotificationScheduler();
    fakeAudio = FakeAudioFeedbackService();
  });

  Widget createSubject({UserProfile? userProfile}) {
    final profile =
        userProfile ??
        const UserProfile(
          userId: 'guest_test_user_1',
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
          selectedLevel: LanguageLevel.little,
        );
    mockProfileRepo = MockProfileRepository(initialProfile: profile);

    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(mockSettingsRepo),
        profileRepositoryProvider.overrideWithValue(mockProfileRepo),
        notificationSchedulerProvider.overrideWithValue(fakeScheduler),
        audioFeedbackServiceProvider.overrideWithValue(fakeAudio),
        versionInfoProvider.overrideWithValue(const MockVersionInfo()),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  group('SettingsScreen Widget Tests', () {
    testWidgets('renders all 8 sections and footer faithfully', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final scrollFinder = find.byType(CustomScrollView);

      // 1. Back link
      expect(find.byType(SettingsBackLink), findsOneWidget);

      // 2. Header and subtitle
      expect(
        find.text(AppStrings.settingsFirstNamePlaceholder),
        findsOneWidget,
      );
      expect(find.text('Spanish learner · Little mode'), findsOneWidget);

      // 3. Courses section
      expect(find.text(AppStrings.settingsCoursesTitle), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
      expect(
        find.text(LevelInfo.forLevel(LanguageLevel.little).name),
        findsOneWidget,
      );
      expect(find.text(AppStrings.settingsShowHelperLineTitle), findsOneWidget);

      // 4. Scroll down to Goal & reminders
      await tester.drag(scrollFinder, const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.settingsGoalRemindersTitle), findsOneWidget);
      expect(find.text(AppStrings.settingsPebbiNudgesTitle), findsOneWidget);

      // 5. Sound and haptics section
      await tester.drag(scrollFinder, const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.settingsSoundHapticsTitle), findsOneWidget);
      expect(find.text(AppStrings.settingsSoundEffectsTitle), findsOneWidget);
      expect(find.text(AppStrings.settingsHapticsTitle), findsOneWidget);
      expect(find.byType(TestSoundTile), findsOneWidget);

      // 6. Appearance section
      await tester.drag(scrollFinder, const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.settingsAppearanceTitle), findsOneWidget);
      expect(find.text(AppStrings.settingsThemeLight), findsOneWidget);
      expect(find.text(AppStrings.settingsThemeDark), findsOneWidget);

      // 7. Accessibility section
      await tester.drag(scrollFinder, const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.settingsAccessibilityTitle), findsOneWidget);
      expect(find.text(AppStrings.settingsReduceMotionTitle), findsOneWidget);
      expect(find.text(AppStrings.settingsCaptionsTitle), findsOneWidget);
      expect(find.text(AppStrings.settingsLeftHandedTitle), findsOneWidget);

      // 8. Account section
      await tester.drag(scrollFinder, const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(find.byType(AccountSection), findsOneWidget);
      expect(find.text(AppStrings.settingsGuestModeTitle), findsOneWidget);
      expect(find.text(AppStrings.settingsSignInAction), findsOneWidget);
      expect(find.byType(DestructiveTile), findsOneWidget);

      // 9. More & Version footer
      await tester.drag(scrollFinder, const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(find.byType(MoreSection), findsOneWidget);
      expect(find.text('Pebbi · version 1.0.0'), findsOneWidget);
    });

    testWidgets('Tapping test sound tile plays sound', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final scrollFinder = find.byType(CustomScrollView);
      await tester.drag(scrollFinder, const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.byType(TestSoundTile), findsOneWidget);
      await tester.tap(find.byType(TestSoundTile));
      await tester.pumpAndSettle();

      expect(fakeAudio.successCount, equals(1));
    });

    testWidgets('Tapping Reset my progress shows confirmation dialog', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final scrollFinder = find.byType(CustomScrollView);
      await tester.drag(scrollFinder, const Offset(0, -1400));
      await tester.pumpAndSettle();

      expect(find.byType(DestructiveTile), findsOneWidget);
      await tester.tap(find.byType(DestructiveTile));
      await tester.pumpAndSettle();

      expect(find.byType(ResetProgressDialog), findsOneWidget);
      expect(find.text(AppStrings.settingsResetDialogTitle), findsOneWidget);
      expect(find.text(AppStrings.settingsResetCancel), findsOneWidget);
      expect(find.text(AppStrings.settingsResetConfirm), findsOneWidget);

      // Cancel closes dialog
      await tester.tap(find.text(AppStrings.settingsResetCancel));
      await tester.pumpAndSettle();

      expect(find.byType(ResetProgressDialog), findsNothing);
    });
  });
}

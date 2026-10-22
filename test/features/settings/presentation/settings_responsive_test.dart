import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/audio_feedback_service.dart';
import 'package:peddi/core/services/fake_notification_scheduler.dart';
import 'package:peddi/core/services/notification_scheduler_provider.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/language_level.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/settings/data/mock_settings_repository.dart';
import 'package:peddi/features/settings/data/mock_version_info.dart';
import 'package:peddi/features/settings/presentation/providers/settings_repository_provider.dart';
import 'package:peddi/features/settings/presentation/providers/version_info_provider.dart';
import 'package:peddi/features/settings/presentation/screens/settings_screen.dart';

void main() {
  const viewports = <String, Size>{
    'Small Android Phone': Size(360, 640),
    'iPhone': Size(390, 844),
    'Large Phone': Size(430, 932),
    'Android Tablet Portrait': Size(800, 1280),
    'Android Tablet Landscape': Size(1280, 800),
    'iPad Pro Portrait': Size(1024, 1366),
    'Split-screen / Foldable': Size(700, 900),
  };

  Widget buildSubject({
    required Size size,
    double textScale = 1.0,
    ThemeMode themeMode = ThemeMode.light,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    const profile = UserProfile(
      userId: 'responsive_tester',
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

    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(MockSettingsRepository()),
        profileRepositoryProvider.overrideWithValue(
          MockProfileRepository(initialProfile: profile),
        ),
        notificationSchedulerProvider.overrideWithValue(
          FakeNotificationScheduler(),
        ),
        audioFeedbackServiceProvider.overrideWithValue(
          FakeAudioFeedbackService(),
        ),
        versionInfoProvider.overrideWithValue(const MockVersionInfo()),
      ],
      child: Directionality(
        textDirection: textDirection,
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            home: const SettingsScreen(),
          ),
        ),
      ),
    );
  }

  group('SettingsScreen Responsive & Text Scale Tests (AGENTS.md §4.8)', () {
    for (final entry in viewports.entries) {
      final name = entry.key;
      final size = entry.value;

      testWidgets(
        'Renders without overflow on $name ($size) at 1.0x text scale in Light mode',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(buildSubject(size: size, textScale: 1.0));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'Renders without overflow on $name ($size) at 2.0x text scale in Dark mode',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'Renders without overflow in RTL (Arabic) on Large Phone at 1.0x',
      (tester) async {
        const size = Size(430, 932);
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildSubject(size: size, textDirection: TextDirection.rtl),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  });
}

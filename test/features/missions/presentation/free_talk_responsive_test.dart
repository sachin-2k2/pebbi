import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/missions/presentation/screens/free_talk_screen.dart';
import 'package:peddi/features/missions/presentation/widgets/free_talk/custom_topic_sheet.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';

void main() {
  const spanishUser = UserProfile(
    userId: 'user_es',
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

  const viewports = <String, Size>{
    '360x640 (Small Android phone)': Size(360, 640),
    '390x844 (iPhone)': Size(390, 844),
    '430x932 (Large phone)': Size(430, 932),
    '800x1280 (Android tablet portrait)': Size(800, 1280),
    '1280x800 (Android tablet landscape)': Size(1280, 800),
    '1024x1366 (iPad Pro portrait)': Size(1024, 1366),
    '700x900 (Split-screen window)': Size(700, 900),
  };

  Widget buildSubject({
    required Size size,
    double textScale = 1.0,
    Brightness brightness = Brightness.light,
    TextDirection direction = TextDirection.ltr,
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) {
    return ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(
          MockProfileRepository(initialProfile: spanishUser),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: brightness,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.brandPurple,
            brightness: brightness,
          ),
          useMaterial3: true,
        ),
        home: Directionality(
          textDirection: direction,
          child: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
              platformBrightness: brightness,
              viewInsets: viewInsets,
            ),
            child: const FreeTalkScreen(),
          ),
        ),
      ),
    );
  }

  group('FreeTalkScreen Responsive Viewport & Text Scale Tests', () {
    for (final entry in viewports.entries) {
      testWidgets('no overflow at ${entry.key} @ 1.0x text scale', (
        tester,
      ) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildSubject(size: entry.value, textScale: 1.0),
        );
        await tester.pump();
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('no overflow at ${entry.key} @ 2.0x text scale', (
        tester,
      ) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildSubject(size: entry.value, textScale: 2.0),
        );
        await tester.pump();
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('FreeTalkScreen Theme & Accessibility Modes', () {
    testWidgets('renders cleanly in dark mode', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildSubject(size: const Size(390, 844), brightness: Brightness.dark),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly in RTL directionality', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildSubject(size: const Size(390, 844), direction: TextDirection.rtl),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('CustomTopicSheet Responsive & Keyboard Tests', () {
    testWidgets('no overflow with keyboard inset open at 390x844', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brandPurple),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                size: Size(390, 844),
                viewInsets: EdgeInsets.only(bottom: 300),
              ),
              child: CustomTopicSheet(onStartTopic: (_) {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow with keyboard inset open at 2.0x text scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brandPurple),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                size: Size(390, 844),
                textScaler: TextScaler.linear(2.0),
                viewInsets: EdgeInsets.only(bottom: 250),
              ),
              child: SingleChildScrollView(
                child: CustomTopicSheet(onStartTopic: (_) {}),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}

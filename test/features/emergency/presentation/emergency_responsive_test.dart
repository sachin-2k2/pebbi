import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/services/wakelock_controller.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/emergency/presentation/screens/emergency_screen.dart';
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

  Widget buildSubject({
    required Size size,
    double textScale = 1.0,
    Brightness brightness = Brightness.light,
    TextDirection direction = TextDirection.ltr,
  }) {
    final fakeWakelock = FakeWakelockController();
    final fakeSpeech = FakeSpeechService();

    return ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(
          MockProfileRepository(initialProfile: spanishUser),
        ),
        wakelockControllerProvider.overrideWithValue(fakeWakelock),
        textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: Directionality(
          textDirection: direction,
          child: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
              platformBrightness: brightness,
            ),
            child: const EmergencyScreen(),
          ),
        ),
      ),
    );
  }

  final testViewports = <String, Size>{
    'Small Android Phone': const Size(360, 640),
    'iPhone': const Size(390, 844),
    'Large Phone': const Size(430, 932),
    'Android Tablet Portrait': const Size(800, 1280),
    'Android Tablet Landscape': const Size(1280, 800),
    'iPad Pro Portrait': const Size(1024, 1366),
    'Split-Screen / Foldable': const Size(700, 900),
  };

  for (final entry in testViewports.entries) {
    testWidgets('EmergencyScreen renders without overflow on ${entry.key}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(entry.value);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildSubject(size: entry.value));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'EmergencyScreen renders without overflow on ${entry.key} at 2.0x text scale',
      (tester) async {
        await tester.binding.setSurfaceSize(entry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          buildSubject(size: entry.value, textScale: 2.0),
        );
        await tester.pump();
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('EmergencyScreen renders cleanly in Dark Mode', (tester) async {
    const size = Size(390, 844);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildSubject(size: size, brightness: Brightness.dark),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('EmergencyScreen renders cleanly in RTL direction', (
    tester,
  ) async {
    const size = Size(390, 844);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildSubject(size: size, direction: TextDirection.rtl),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

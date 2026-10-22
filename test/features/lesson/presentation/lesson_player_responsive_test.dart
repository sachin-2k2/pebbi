import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/audio_feedback_service.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/lesson/presentation/screens/exercise_screen.dart';

void main() {
  group('Lesson Player Responsive & Overflow Tests', () {
    late FakeSpeechService fakeSpeech;
    late FakeAudioFeedbackService fakeAudio;

    setUp(() {
      fakeSpeech = FakeSpeechService();
      fakeAudio = FakeAudioFeedbackService();
    });

    Widget createScreen({
      String stopId = '1',
      ThemeData? theme,
      double textScaleFactor = 1.0,
      TextDirection textDirection = TextDirection.ltr,
    }) {
      return ProviderScope(
        overrides: [
          textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
          audioFeedbackServiceProvider.overrideWithValue(fakeAudio),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.light(),
          builder: (context, child) {
            return Directionality(
              textDirection: textDirection,
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(textScaleFactor)),
                child: child!,
              ),
            );
          },
          home: ExerciseScreen(stopId: stopId),
        ),
      );
    }

    final viewports = [
      (width: 360.0, height: 640.0, label: '360x640 (Small Android)'),
      (width: 390.0, height: 844.0, label: '390x844 (iPhone)'),
      (width: 430.0, height: 932.0, label: '430x932 (Large Phone)'),
      (width: 800.0, height: 1280.0, label: '800x1280 (Tablet Portrait)'),
      (width: 1280.0, height: 800.0, label: '1280x800 (Tablet Landscape)'),
      (width: 1024.0, height: 1366.0, label: '1024x1366 (iPad Pro Portrait)'),
      (width: 700.0, height: 900.0, label: '700x900 (Split Screen / Foldable)'),
    ];

    for (final vp in viewports) {
      testWidgets('Renders cleanly without overflow at ${vp.label}', (
        tester,
      ) async {
        tester.view.physicalSize = Size(vp.width, vp.height);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        expect(find.byType(ExerciseScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Renders cleanly at 200% text scale without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390.0, 844.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createScreen(textScaleFactor: 2.0));
      await tester.pumpAndSettle();

      expect(find.byType(ExerciseScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders cleanly in dark mode without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390.0, 844.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createScreen(theme: AppTheme.dark()));
      await tester.pumpAndSettle();

      expect(find.byType(ExerciseScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders Arabic RTL lesson without overflow', (tester) async {
      tester.view.physicalSize = const Size(390.0, 844.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createScreen(stopId: 'arabic_1', textDirection: TextDirection.rtl),
      );
      await tester.pumpAndSettle();

      expect(find.text('مَرْحَبًا'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Renders very long phrase variant at 200% text scale without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(390.0, 844.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          createScreen(stopId: 'long_1', textScaleFactor: 2.0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ExerciseScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

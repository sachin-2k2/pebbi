import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/features/path/presentation/widgets/unit_guide/unit_guide_sheet.dart';

void main() {
  late FakeSpeechService fakeTts;

  setUp(() {
    fakeTts = FakeSpeechService();
    UnitGuideSheet.clearSavedScrollOffsets();
  });

  Widget buildSubject({
    required Size size,
    double textScale = 1.0,
    String unitId = 'unit_1',
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return ProviderScope(
      overrides: [textToSpeechServiceProvider.overrideWithValue(fakeTts)],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brandPurple),
          useMaterial3: true,
        ),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: Directionality(
            textDirection: textDirection,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        UnitGuideSheet.show(context, unitId: unitId);
                      },
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('UnitGuideSheet Responsive & Overflow Tests (AGENTS.md §4.8)', () {
    final sizes = <(String, Size)>[
      ('Small Android Phone (360 x 640 dp)', const Size(360, 640)),
      ('iPhone (390 x 844 dp)', const Size(390, 844)),
      ('Android Tablet Portrait (800 x 1280 dp)', const Size(800, 1280)),
      ('Android Tablet Landscape (1280 x 800 dp)', const Size(1280, 800)),
      ('iPad Pro Portrait (1024 x 1366 dp)', const Size(1024, 1366)),
      ('Split-screen / Foldable Window (700 x 900 dp)', const Size(700, 900)),
    ];

    for (final (label, size) in sizes) {
      testWidgets(
        'renders cleanly with 0 overflows at $label (textScale 1.0)',
        (tester) async {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(buildSubject(size: size));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          expect(find.byType(UnitGuideSheet), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'renders cleanly with 0 overflows at $label (textScale 2.0)',
        (tester) async {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(buildSubject(size: size, textScale: 2.0));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          expect(find.byType(UnitGuideSheet), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('renders RTL Arabic guidebook cleanly with 0 overflows', (
      tester,
    ) async {
      const size = Size(390, 844);
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        buildSubject(
          size: size,
          unitId: 'unit_arabic_1',
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(UnitGuideSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/api_client.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/presentation/screens/placement_intro_screen.dart';
import 'package:peddi/features/onboarding/presentation/screens/placement_result_screen.dart';
import '../../../core/network/fake_http_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testSizes = <String, Size>{
    'Small Phone (360x640)': const Size(360, 640),
    'iPhone (390x844)': const Size(390, 844),
    'Tablet Portrait (800x1280)': const Size(800, 1280),
    'Tablet Landscape (1280x800)': const Size(1280, 800),
    'iPad Pro (1024x1366)': const Size(1024, 1366),
  };

  group('Placement Screens - Responsive and Text Scale Tests', () {
    late FakeHttpClientAdapter fakeAdapter;

    setUp(() {
      fakeAdapter = FakeHttpClientAdapter();

      final questionsJson = File(
        'test/fixtures/api/placement_questions_200.json',
      ).readAsStringSync();
      fakeAdapter.onJson('/api/placement/questions', questionsJson);
    });

    for (final sizeEntry in testSizes.entries) {
      final name = sizeEntry.key;
      final size = sizeEntry.value;

      testWidgets('PlacementIntroScreen at $name (scale 1.0 and 2.0)', (
        tester,
      ) async {
        for (final scale in [1.0, 2.0]) {
          tester.view.physicalSize = size * 2.0;
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                apiClientProvider.overrideWith(
                  (ref) => ApiClient(adapter: fakeAdapter),
                ),
              ],
              child: MaterialApp(
                theme: AppTheme.light(),
                home: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: const PlacementIntroScreen(),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        }
        addTearDown(tester.view.resetPhysicalSize);
      });

      testWidgets('PlacementResultScreen at $name in dark mode', (
        tester,
      ) async {
        tester.view.physicalSize = size * 2.0;
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              apiClientProvider.overrideWith(
                (ref) => ApiClient(adapter: fakeAdapter),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.dark(),
              home: MediaQuery(
                data: MediaQueryData(size: size),
                child: const PlacementResultScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        addTearDown(tester.view.resetPhysicalSize);
      });
    }
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/review/data/fake_share_service.dart';
import 'package:peddi/features/review/presentation/providers/review_provider.dart';
import 'package:peddi/features/rewards/data/mock_rewards_repository.dart';
import 'package:peddi/features/rewards/presentation/providers/rewards_provider.dart';
import 'package:peddi/features/rewards/presentation/screens/rewards_screen.dart';

void main() {
  const viewports = <String, Size>{
    '360x640 (Small Android phone)': Size(360, 640),
    '390x844 (iPhone)': Size(390, 844),
    '430x932 (Large phone)': Size(430, 932),
    '800x1280 (Tablet portrait)': Size(800, 1280),
    '1280x800 (Tablet landscape)': Size(1280, 800),
    '1024x1366 (iPad Pro portrait)': Size(1024, 1366),
    '700x900 (Split-screen window)': Size(700, 900),
  };

  group('Rewards Responsive Layout Tests (AGENTS.md §4.8)', () {
    for (final entry in viewports.entries) {
      for (final textScale in [1.0, 2.0]) {
        for (final isDark in [false, true]) {
          testWidgets(
            'Renders on ${entry.key} with textScale: $textScale dark: $isDark without overflow',
            (tester) async {
              tester.view.physicalSize = entry.value;
              tester.view.devicePixelRatio = 1.0;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);

              final repo = MockRewardsRepository(
                initialSummary: MockRewardsRepository.createScreenshotDefault(),
              );

              await tester.pumpWidget(
                ProviderScope(
                  overrides: [
                    rewardsRepositoryProvider.overrideWithValue(repo),
                    shareServiceProvider.overrideWithValue(FakeShareService()),
                  ],
                  child: MaterialApp(
                    theme: AppTheme.light(),
                    darkTheme: AppTheme.dark(),
                    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                    home: MediaQuery(
                      data: MediaQueryData(
                        size: entry.value,
                        textScaler: TextScaler.linear(textScale),
                      ),
                      child: const RewardsScreen(),
                    ),
                  ),
                ),
              );

              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }

    testWidgets('Renders cleanly in RTL direction without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = MockRewardsRepository(
        initialSummary: MockRewardsRepository.createMidState(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rewardsRepositoryProvider.overrideWithValue(repo),
            shareServiceProvider.overrideWithValue(FakeShareService()),
          ],
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: MediaQuery(
                data: const MediaQueryData(
                  size: Size(390, 844),
                  textScaler: TextScaler.linear(1.5),
                ),
                child: const RewardsScreen(),
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

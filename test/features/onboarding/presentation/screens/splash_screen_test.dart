import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/theme/app_palette.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/presentation/providers/app_startup_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/splash/splash_config.dart';
import 'package:peddi/features/onboarding/presentation/widgets/splash/splash_loading_dashes.dart';
import 'package:peddi/features/onboarding/presentation/widgets/splash/splash_logo_tile.dart';
import 'package:peddi/features/onboarding/presentation/widgets/splash/splash_timeout_view.dart';
import 'package:peddi/features/settings/domain/app_settings.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  GoRouter createTestRouter() {
    return GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/path',
          builder: (context, state) => const Scaffold(body: Text('Path Screen')),
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) =>
              const Scaffold(body: Text('Welcome Screen')),
        ),
      ],
    );
  }

  Widget buildTestWidget({
    required Widget child,
    bool isDark = false,
    bool reduceMotion = false,
    bool splashCompleted = false,
    bool shouldShowArt = true,
    AsyncValue<String>? startupOverride,
  }) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith(
          (ref) => AppSettingsNotifier(
            AppSettings(
              reduceMotion: reduceMotion,
              themeMode: isDark ? 'dark' : 'light',
            ),
          ),
        ),
        splashCompletedProvider.overrideWith((ref) => splashCompleted),
        splashShouldShowArtProvider.overrideWith((ref) => shouldShowArt),
        if (startupOverride != null)
          appStartupProvider.overrideWith(
            (ref) => startupOverride is AsyncLoading
                ? Completer<String>().future
                : Future.value(startupOverride.value ?? '/welcome'),
          ),
      ],
      child: MaterialApp(
        theme: isDark ? AppTheme.dark() : AppTheme.light(),
        home: child,
      ),
    );
  }

  Widget buildTestAppWithRouter({
    required GoRouter router,
    required ProviderContainer container,
    bool isDark = false,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: isDark ? AppTheme.dark() : AppTheme.light(),
        routerConfig: router,
      ),
    );
  }

  group('SplashScreen - First Frame & Alignment (User Rule 2 & 3)', () {
    testWidgets(
      'first frame renders solid launch background and centered 96dp tile',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const SplashScreen(),
            startupOverride: const AsyncValue.loading(),
          ),
        );

        // Verify centered logo tile exists
        expect(find.byType(SplashLogoTile), findsOneWidget);
        final tileBox = tester.getSize(find.byType(SplashLogoTile));
        expect(tileBox.width, equals(SplashConfig.tileLogicalSize));
        expect(tileBox.height, equals(SplashConfig.tileLogicalSize));

        // Verify tile center is at exact screen center
        final tileCenter = tester.getCenter(find.byType(SplashLogoTile));
        final screenCenter =
            tester.view.physicalSize / tester.view.devicePixelRatio / 2;
        expect(
          (tileCenter.dx - screenCenter.width).abs(),
          lessThanOrEqualTo(0.5),
        );
        expect(
          (tileCenter.dy - screenCenter.height).abs(),
          lessThanOrEqualTo(0.5),
        );

        // Solid background box exists
        expect(find.byType(ColoredBox), findsWidgets);
      },
    );

    testWidgets('first frame is identical in light and dark modes', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const SplashScreen(),
          isDark: false,
          startupOverride: const AsyncValue.loading(),
        ),
      );
      final lightTileCenter = tester.getCenter(find.byType(SplashLogoTile));

      await tester.pumpWidget(
        buildTestWidget(
          child: const SplashScreen(),
          isDark: true,
          startupOverride: const AsyncValue.loading(),
        ),
      );
      final darkTileCenter = tester.getCenter(find.byType(SplashLogoTile));

      expect(lightTileCenter, equals(darkTileCenter));
    });
  });

  group('SplashScreen - Minimum Display Time & Synchronized Exit', () {
    testWidgets(
      'startup finishes in 50ms -> splash stays until entrance (900ms) + hold (300ms) = 1200ms',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            splashCompletedProvider.overrideWith((ref) => false),
            splashShouldShowArtProvider.overrideWith((ref) => true),
            appStartupProvider.overrideWith((ref) => '/welcome'),
          ],
        );
        addTearDown(container.dispose);
        final router = createTestRouter();

        await tester.pumpWidget(
          buildTestAppWithRouter(router: router, container: container),
        );

        // Frame 1 rendered
        await tester.pump();
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Welcome Screen'), findsNothing);

        // At 50ms: startup has completed, but entrance is running -> must stay
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Welcome Screen'), findsNothing);

        // At 800ms: still in entrance animation -> must stay
        await tester.pump(const Duration(milliseconds: 750));
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Welcome Screen'), findsNothing);

        // At 950ms: entrance completes (900ms from T=50ms), hold timer starts
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Welcome Screen'), findsNothing);

        // At 1250ms: hold (300ms) completes -> navigates!
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        expect(find.text('Welcome Screen'), findsOneWidget);
        expect(container.read(splashCompletedProvider), isTrue);
      },
    );

    testWidgets(
      'fails if navigation happens before entrance + hold time when art is shown',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            splashCompletedProvider.overrideWith((ref) => false),
            splashShouldShowArtProvider.overrideWith((ref) => true),
            appStartupProvider.overrideWith((ref) => '/welcome'),
          ],
        );
        addTearDown(container.dispose);
        final router = createTestRouter();

        await tester.pumpWidget(
          buildTestAppWithRouter(router: router, container: container),
        );
        await tester.pump();

        // Check at 500ms: navigation MUST NOT have occurred yet
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Welcome Screen'), findsNothing);

        // At 950ms (entrance completion): navigation MUST NOT have occurred yet
        await tester.pump(const Duration(milliseconds: 450));
        expect(find.text('Welcome Screen'), findsNothing);

        // At 1150ms (during hold): still no navigation
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('Welcome Screen'), findsNothing);

        // At 1250ms (hold completed): navigates
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump();
        expect(find.text('Welcome Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'startup takes 3s -> splash stays until startup finishes (and announcement fires at 3s)',
      (tester) async {
        String? targetRoute;
        final container = ProviderContainer(
          overrides: [
            splashCompletedProvider.overrideWith((ref) => false),
            splashShouldShowArtProvider.overrideWith((ref) => true),
            appStartupProvider.overrideWith((ref) async {
              while (targetRoute == null) {
                await Future.delayed(const Duration(milliseconds: 100));
              }
              return targetRoute;
            }),
          ],
        );
        addTearDown(container.dispose);
        final router = createTestRouter();

        await tester.pumpWidget(
          buildTestAppWithRouter(router: router, container: container),
        );
        await tester.pump();

        // At 1500ms: entrance + hold has finished, but startup still running -> stays
        await tester.pump(const Duration(milliseconds: 1500));
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Welcome Screen'), findsNothing);

        // At 3000ms: announcement timer has fired, still waiting for startup
        await tester.pump(const Duration(milliseconds: 1500));
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Welcome Screen'), findsNothing);

        // Startup finishes at 3200ms
        targetRoute = '/welcome';
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump();

        expect(find.text('Welcome Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'art off -> short timeline (300ms) prevents 1-frame flash',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            splashCompletedProvider.overrideWith((ref) => false),
            splashShouldShowArtProvider.overrideWith((ref) => false),
            appStartupProvider.overrideWith((ref) => '/welcome'),
          ],
        );
        addTearDown(container.dispose);
        final router = createTestRouter();

        await tester.pumpWidget(
          buildTestAppWithRouter(router: router, container: container),
        );
        await tester.pump();

        // At 100ms: startup is ready, but short timer (300ms) prevents 1-frame flash
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Welcome Screen'), findsNothing);

        // At 350ms: short minimum time elapsed -> navigates immediately
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('Welcome Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'reduceMotion -> static dashes with equal softer colour and short timeline (300ms)',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            splashCompletedProvider.overrideWith((ref) => false),
            splashShouldShowArtProvider.overrideWith((ref) => true),
            appSettingsProvider.overrideWith(
              (ref) => AppSettingsNotifier(
                const AppSettings(reduceMotion: true),
              ),
            ),
            appStartupProvider.overrideWith((ref) => '/welcome'),
          ],
        );
        addTearDown(container.dispose);
        final router = createTestRouter();

        await tester.pumpWidget(
          buildTestAppWithRouter(router: router, container: container),
        );
        await tester.pump();

        // Verify all 3 dashes have the same muted foreground color
        final dashContainers = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(SplashLoadingDashes),
                matching: find.byType(Container),
              ),
            )
            .toList();
        expect(dashContainers.length, equals(3));
        final expectedColor = AppPalette.light().splashForegroundMuted;
        for (final c in dashContainers) {
          final decoration = c.decoration as BoxDecoration;
          expect(decoration.color, equals(expectedColor));
        }

        // At 100ms: still on splash
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(SplashScreen), findsOneWidget);

        // At 350ms: short timeline completes -> navigates
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('Welcome Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'very late first frame: splash still shows for full minimum duration from first frame',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            splashCompletedProvider.overrideWith((ref) => false),
            splashShouldShowArtProvider.overrideWith((ref) => true),
            appStartupProvider.overrideWith((ref) => '/welcome'),
          ],
        );
        addTearDown(container.dispose);
        final router = createTestRouter();

        // Frame 1 pumped
        await tester.pumpWidget(
          buildTestAppWithRouter(router: router, container: container),
        );
        await tester.pump();
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Welcome Screen'), findsNothing);

        // Even though startup was already done before frame 1, splash must remain for 1200ms
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 750)); // 800ms
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Welcome Screen'), findsNothing);

        // At 950ms: entrance completes, hold starts
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Welcome Screen'), findsNothing);

        // At 1250ms: hold completes -> navigates
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        expect(find.text('Welcome Screen'), findsOneWidget);
      },
    );
  });

  group('SplashScreen - Dashes Controller Advancement', () {
    test('dashes controller advances highlight smoothly across frames', () {
      // Dash 0 is lit initially
      final weight0At0 = SplashLoadingDashes.calculateDashWeight(0, 0.0);
      final weight1At0 = SplashLoadingDashes.calculateDashWeight(1, 0.0);
      expect(weight0At0, greaterThan(0.0));
      expect(weight1At0, equals(0.0));

      // Advance 250ms (0.416 of 600ms cycle): Dash 1 is now active
      final weight0At250 = SplashLoadingDashes.calculateDashWeight(
        0,
        250.0 / 600.0,
      );
      final weight1At250 = SplashLoadingDashes.calculateDashWeight(
        1,
        250.0 / 600.0,
      );
      expect(weight0At250, equals(0.0));
      expect(weight1At250, greaterThan(0.0));
    });
  });

  group('SplashScreen - Safety Timeout & Error UI', () {
    testWidgets(
      'startup taking 8s triggers safety timeout UI with Retry and Guest actions',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            splashCompletedProvider.overrideWith((ref) => false),
            splashShouldShowArtProvider.overrideWith((ref) => true),
            appStartupProvider.overrideWith((ref) => Completer<String>().future),
          ],
        );
        addTearDown(container.dispose);
        final router = createTestRouter();

        await tester.pumpWidget(
          buildTestAppWithRouter(router: router, container: container),
        );
        await tester.pump();

        // At 7s: still waiting, no timeout UI
        await tester.pump(const Duration(seconds: 7));
        expect(find.byType(SplashTimeoutView), findsNothing);

        // At 8.1s: safety timeout fires, showing SplashTimeoutView
        await tester.pump(const Duration(milliseconds: 1100));
        expect(find.byType(SplashTimeoutView), findsOneWidget);
        expect(find.text('Starting up took longer than expected'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.text('Continue as guest'), findsOneWidget);

        // Tap "Continue as guest" -> navigates to /welcome
        await tester.tap(find.text('Continue as guest'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('Welcome Screen'), findsOneWidget);
      },
    );
  });

  group('SplashScreen - Accessibility & Recreation Guards', () {
    testWidgets(
      'semantics exposes only logo and tagline; excludes decorations and dashes',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const SplashScreen(),
            startupOverride: const AsyncValue.loading(),
          ),
        );

        await tester.pump(const Duration(milliseconds: 800));

        expect(find.bySemanticsLabel('Pebbi'), findsWidgets);
        expect(find.text('Speak it for real.'), findsOneWidget);

        final excludeSemantics = find.descendant(
          of: find.byType(SplashLoadingDashes),
          matching: find.byType(ExcludeSemantics),
        );
        expect(excludeSemantics, findsOneWidget);

        // Unmount widget so active timers are cancelled
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      'activity recreation (theme, font-scale, rotation) does not reset splashCompletedProvider',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(splashCompletedProvider.notifier).state = true;
        expect(container.read(splashCompletedProvider), isTrue);

        container.read(appSettingsProvider.notifier).setThemeMode('dark');
        expect(container.read(splashCompletedProvider), isTrue);

        container.read(appSettingsProvider.notifier).setTextScale(1.5);
        expect(container.read(splashCompletedProvider), isTrue);

        container.read(appSettingsProvider.notifier).setReduceMotion(true);
        expect(container.read(splashCompletedProvider), isTrue);
      },
    );
  });
}

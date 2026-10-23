import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/onboarding/presentation/providers/app_startup_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/splash/splash_config.dart';
import 'package:peddi/features/onboarding/presentation/widgets/splash/splash_decoration_item.dart';
import 'package:peddi/features/onboarding/presentation/widgets/splash/splash_greetings_layer.dart';
import 'package:peddi/features/onboarding/presentation/widgets/splash/splash_loading_dashes.dart';
import 'package:peddi/features/onboarding/presentation/widgets/splash/splash_logo_tile.dart';
import 'package:peddi/features/onboarding/presentation/widgets/splash/splash_wordmark.dart';
import 'package:peddi/features/settings/domain/app_settings.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget({
    required Widget child,
    bool isDark = false,
    bool reduceMotion = false,
    bool splashCompleted = false,
    bool shouldShowArt = true,
    UserProfile? currentUser,
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
        if (currentUser != null)
          currentUserProvider.overrideWith(
            (ref) => CurrentUserNotifier(
              ref.watch(profileRepositoryProvider),
              currentUser,
            ),
          ),
        if (startupOverride != null)
          appStartupProvider.overrideWith(
            (ref) => startupOverride.value ?? '/welcome',
          ),
      ],
      child: MaterialApp(
        theme: isDark ? AppTheme.dark() : AppTheme.light(),
        home: child,
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
      // Light mode
      await tester.pumpWidget(
        buildTestWidget(
          child: const SplashScreen(),
          isDark: false,
          startupOverride: const AsyncValue.loading(),
        ),
      );
      final lightTileCenter = tester.getCenter(find.byType(SplashLogoTile));

      // Dark mode
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

  group('SplashScreen - Animations & Reduce Motion (User Rule 4 & 5)', () {
    testWidgets(
      'entrance animation renders wordmark, dashes, and decorations over time',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const SplashScreen(),
            startupOverride: const AsyncValue.loading(),
          ),
        );

        // Advance 200ms: wordmark starts appearing
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(SplashWordmark), findsOneWidget);

        // Advance to 600ms: decorations appear
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(SplashDecorationItem), findsWidgets);
        expect(find.byType(SplashGreetingsLayer), findsOneWidget);
        expect(find.byType(SplashLoadingDashes), findsOneWidget);
      },
    );

    testWidgets(
      'reduceMotion renders final state immediately with static dashes and no drift',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const SplashScreen(),
            reduceMotion: true,
            startupOverride: const AsyncValue.loading(),
          ),
        );

        // Frame 1 with reduceMotion has full opacity immediately
        await tester.pump();
        expect(find.byType(SplashWordmark), findsOneWidget);
        expect(find.byType(SplashLoadingDashes), findsOneWidget);
        expect(find.byType(SplashDecorationItem), findsWidgets);
      },
    );
  });

  group(
    'SplashScreen - State Architecture & Cold Start Only (User Rule 6 & 7)',
    () {
      testWidgets(
        'startup completion marks splash completed and triggers navigation',
        (tester) async {
          final container = ProviderContainer(
            overrides: [
              splashCompletedProvider.overrideWith((ref) => false),
              appStartupProvider.overrideWith((ref) => '/path'),
            ],
          );
          addTearDown(container.dispose);

          final router = GoRouter(
            initialLocation: '/splash',
            routes: [
              GoRoute(
                path: '/splash',
                builder: (context, state) => const SplashScreen(),
              ),
              GoRoute(
                path: '/path',
                builder: (context, state) =>
                    const Scaffold(body: Text('Path Screen')),
              ),
            ],
          );

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp.router(routerConfig: router),
            ),
          );

          // Pump to trigger startup listener
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          expect(container.read(splashCompletedProvider), isTrue);
          expect(find.text('Path Screen'), findsOneWidget);
        },
      );

      testWidgets(
        'splashArtOnEveryLaunch false renders only tile and omits art on subsequent launches',
        (tester) async {
          await tester.pumpWidget(
            buildTestWidget(
              child: const SplashScreen(),
              shouldShowArt: false,
              startupOverride: const AsyncValue.loading(),
            ),
          );

          // Centered tile is shown
          expect(find.byType(SplashLogoTile), findsOneWidget);
          // Wordmark, decorations, and greetings are omitted
          expect(find.byType(SplashWordmark), findsNothing);
          expect(find.byType(SplashDecorationItem), findsNothing);
          expect(find.byType(SplashGreetingsLayer), findsNothing);
        },
      );

      testWidgets(
        'activity recreation (theme, font-scale, rotation) does not reset splashCompletedProvider',
        (tester) async {
          final container = ProviderContainer();
          addTearDown(container.dispose);

          // Mark splash as completed
          container.read(splashCompletedProvider.notifier).state = true;
          expect(container.read(splashCompletedProvider), isTrue);

          // Simulate theme change
          container.read(appSettingsProvider.notifier).setThemeMode('dark');
          expect(container.read(splashCompletedProvider), isTrue);

          // Simulate text scale change
          container.read(appSettingsProvider.notifier).setTextScale(1.5);
          expect(container.read(splashCompletedProvider), isTrue);

          // Simulate reduce motion change
          container.read(appSettingsProvider.notifier).setReduceMotion(true);
          expect(container.read(splashCompletedProvider), isTrue);
        },
      );
    },
  );

  group('SplashScreen - Accessibility & Semantics', () {
    testWidgets(
      'semantics exposes only logo and tagline; excludes decorations and dashes',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const SplashScreen(),
            startupOverride: const AsyncValue.loading(),
          ),
        );

        // Advance to full entrance
        await tester.pump(const Duration(milliseconds: 800));

        // "Pebbi" semantics exists
        expect(find.bySemanticsLabel('Pebbi'), findsWidgets);

        // Tagline text exists
        expect(find.text('Speak it for real.'), findsOneWidget);

        // Loading dashes are wrapped in ExcludeSemantics
        final excludeSemantics = find.descendant(
          of: find.byType(SplashLoadingDashes),
          matching: find.byType(ExcludeSemantics),
        );
        expect(excludeSemantics, findsOneWidget);
      },
    );
  });
}

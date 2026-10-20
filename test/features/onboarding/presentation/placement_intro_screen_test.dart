import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/benefit_chip.dart';
import 'package:peddi/core/design_system/button_3d.dart';
import 'package:peddi/core/design_system/info_card.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/core/theme/app_spacing.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/domain/language_level.dart';
import 'package:peddi/features/onboarding/domain/onboarding_config.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/placement_intro_screen.dart';
import 'package:peddi/features/onboarding/presentation/screens/placement_quiz_stub_screen.dart';
import 'package:peddi/features/onboarding/presentation/screens/reason_step_screen.dart';
import 'package:peddi/features/onboarding/presentation/screens/setup_stub_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/benefit_chip_row.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_footer_button.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_progress_header.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_title_block.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('PlacementIntroScreen Widget & Content Tests', () {
    Widget createScreen({
      VoidCallback? onStartQuiz,
      VoidCallback? onSkipToLevel,
      VoidCallback? onBack,
      ProviderContainer? container,
      ThemeData? theme,
    }) {
      final app = MaterialApp(
        theme: theme ?? AppTheme.light(),
        home: PlacementIntroScreen(
          onStartQuiz: onStartQuiz,
          onSkipToLevel: onSkipToLevel,
          onBack: onBack,
        ),
      );

      return container != null
          ? UncontrolledProviderScope(container: container, child: app)
          : ProviderScope(child: app);
    }

    testWidgets('renders header 6/11, title with mascot, cards, and chips', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // 1. Header (6/11)
      expect(find.byType(StepProgressHeader), findsOneWidget);
      expect(find.text('6/11'), findsOneWidget);

      // 2. Title block with purple mascot
      expect(find.byType(StepTitleBlock), findsOneWidget);
      expect(find.text(AppStrings.placementIntroTitle), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(StepTitleBlock),
          matching: find.byType(PebbiMascot),
        ),
        findsOneWidget,
      );

      // 3. Two InfoCards with exact titles & bodies
      expect(find.byType(InfoCard), findsNWidgets(2));
      expect(find.text(AppStrings.placementCard1Title), findsOneWidget);
      expect(find.text(AppStrings.placementCard1Body), findsOneWidget);
      expect(find.text(AppStrings.placementCard2Title), findsOneWidget);
      expect(find.text(AppStrings.placementCard2Body), findsOneWidget);

      // 4. BenefitChipRow with all three chips
      expect(find.byType(BenefitChipRow), findsOneWidget);
      expect(find.byType(BenefitChip), findsNWidgets(3));
      expect(find.text(AppStrings.placementChipNoTimer), findsOneWidget);
      expect(find.text(AppStrings.placementChipSkipAnything), findsOneWidget);
      expect(find.text(AppStrings.placementChipEndsInAWin), findsOneWidget);

      // 5. Pinned bottom buttons
      expect(find.byType(StepFooterButton), findsOneWidget);
      expect(find.text(AppStrings.placementStartButton), findsOneWidget);
      expect(
        find.text(
          AppStrings.placementSkipAction(
            OnboardingConfig.defaultLowestLevel.label,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'dynamic subtitle renders target language, 8 questions, 2 minutes and updates on language change',
      (tester) async {
        final container = ProviderContainer();

        await tester.pumpWidget(createScreen(container: container));
        await tester.pumpAndSettle();

        // Default target language is 'es' (Spanish)
        expect(
          find.text('Eight quick ones in Spanish. About two minutes.'),
          findsOneWidget,
        );

        // Switch to French ('fr')
        container
            .read(onboardingFlowProvider.notifier)
            .setTargetLanguageCode('fr');
        await tester.pumpAndSettle();

        expect(
          find.text('Eight quick ones in French. About two minutes.'),
          findsOneWidget,
        );

        // Switch to Japanese ('ja')
        container
            .read(onboardingFlowProvider.notifier)
            .setTargetLanguageCode('ja');
        await tester.pumpAndSettle();

        expect(
          find.text('Eight quick ones in Japanese. About two minutes.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tapping "Start the quick check" triggers callback and updates step',
      (tester) async {
        final container = ProviderContainer();
        var startQuizCalled = false;

        await tester.pumpWidget(
          createScreen(
            container: container,
            onStartQuiz: () => startQuizCalled = true,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text(AppStrings.placementStartButton));
        await tester.pumpAndSettle();

        expect(startQuizCalled, isTrue);
        expect(container.read(onboardingFlowProvider).currentStep, equals(6));
      },
    );

    testWidgets(
      'tapping secondary action stores lowest level (Little), marks skipped, and triggers callback',
      (tester) async {
        final container = ProviderContainer();
        var skipCalled = false;

        await tester.pumpWidget(
          createScreen(
            container: container,
            onSkipToLevel: () => skipCalled = true,
          ),
        );
        await tester.pumpAndSettle();

        final skipLabel = AppStrings.placementSkipAction(
          OnboardingConfig.defaultLowestLevel.label,
        );
        await tester.tap(find.text(skipLabel));
        await tester.pumpAndSettle();

        expect(skipCalled, isTrue);

        final state = container.read(onboardingFlowProvider);
        expect(state.selectedLevel, equals(LanguageLevel.little));
        expect(state.isPlacementSkipped, isTrue);
        expect(state.currentStep, equals(7));
      },
    );

    testWidgets(
      'secondary text action has a minimum tap target height of at least 48dp',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        final skipLabel = AppStrings.placementSkipAction(
          OnboardingConfig.defaultLowestLevel.label,
        );
        final finder = find.ancestor(
          of: find.text(skipLabel),
          matching: find.byType(ConstrainedBox),
        );
        expect(finder, findsWidgets);

        final constrainedBox = tester.widget<ConstrainedBox>(finder.first);
        expect(
          constrainedBox.constraints.minHeight,
          greaterThanOrEqualTo(AppSpacing.minTouchTarget),
        );
      },
    );

    testWidgets('sparkle icons are decorative and excluded from semantics', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      final excludedIcons = find.descendant(
        of: find.byType(ExcludeSemantics),
        matching: find.byIcon(Icons.auto_awesome),
      );
      expect(excludedIcons, findsNWidgets(3));
    });

    testWidgets('title has header semantics and buttons have semantic labels', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Title header
      final headerSemantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.header == true,
      );
      expect(headerSemantics, findsOneWidget);

      // Mint button semantics
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Button3D &&
              w.label == AppStrings.placementStartButton &&
              w.backgroundColor == AppColors.mint,
        ),
        findsOneWidget,
      );
    });
  });

  group('PlacementIntroScreen Router Navigation Tests', () {
    GoRouter createTestRouter(ProviderContainer container) {
      return GoRouter(
        initialLocation: '/onboarding/setup/step-6',
        routes: [
          GoRoute(
            path: '/onboarding/setup/step-5',
            builder: (context, state) => const ReasonStepScreen(),
          ),
          GoRoute(
            path: '/onboarding/setup/step-6',
            builder: (context, state) => const PlacementIntroScreen(),
          ),
          GoRoute(
            path: '/onboarding/placement-quiz',
            builder: (context, state) => const PlacementQuizStubScreen(),
          ),
          GoRoute(
            path: '/onboarding/setup/step-7',
            builder: (context, state) => const SetupStubScreen(stepNumber: 7),
          ),
        ],
      );
    }

    testWidgets(
      '"Start the quick check" navigates to placeholder quiz route and returns cleanly',
      (tester) async {
        final container = ProviderContainer();
        final router = createTestRouter(container);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: AppTheme.light(),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PlacementIntroScreen), findsOneWidget);

        // Tap Start the quick check
        await tester.tap(find.text(AppStrings.placementStartButton));
        await tester.pumpAndSettle();

        // Navigates to PlacementQuizStubScreen
        expect(find.byType(PlacementQuizStubScreen), findsOneWidget);
        expect(find.text('Placement Quiz (Coming Soon)'), findsOneWidget);

        // Tap back button in quiz stub
        await tester.tap(find.bySemanticsLabel(AppStrings.backSemantics));
        await tester.pumpAndSettle();

        // Returns to PlacementIntroScreen
        expect(find.byType(PlacementIntroScreen), findsOneWidget);
      },
    );

    testWidgets(
      'secondary action navigates to Step 7 placeholder and stores Little level',
      (tester) async {
        final container = ProviderContainer();
        final router = createTestRouter(container);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: AppTheme.light(),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final skipLabel = AppStrings.placementSkipAction(
          OnboardingConfig.defaultLowestLevel.label,
        );
        await tester.tap(find.text(skipLabel));
        await tester.pumpAndSettle();

        // Navigates to Step 7
        expect(find.byType(SetupStubScreen), findsOneWidget);
        expect(find.text('Step 7 of 11 (Coming Soon)'), findsOneWidget);

        final state = container.read(onboardingFlowProvider);
        expect(state.selectedLevel, equals(LanguageLevel.little));
        expect(state.isPlacementSkipped, isTrue);
      },
    );

    testWidgets('back button navigates to step 5 preserving previous state', (
      tester,
    ) async {
      final container = ProviderContainer();
      container.read(onboardingFlowProvider.notifier).setReasonIds({'travel'});
      final router = createTestRouter(container);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PlacementIntroScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.bySemanticsLabel(AppStrings.backSemantics));
      await tester.pumpAndSettle();

      // Navigates to Step 5 (ReasonStepScreen)
      expect(find.byType(ReasonStepScreen), findsOneWidget);

      // State is preserved
      expect(
        container.read(onboardingFlowProvider).selectedReasonIds,
        equals({'travel'}),
      );

      // Tap continue from Step 5 to return to Step 6
      await tester.tap(find.text(AppStrings.continueAction));
      await tester.pumpAndSettle();

      expect(find.byType(PlacementIntroScreen), findsOneWidget);
    });
  });

  group('PlacementIntroScreen Responsive & Overflow Tests', () {
    const testSizes = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(800, 1280), // Android tablet portrait
      Size(1280, 800), // Android tablet landscape
      Size(1024, 1366), // iPad Pro portrait
      Size(700, 900), // Foldable / split screen
    ];

    for (final size in testSizes) {
      testWidgets(
        'renders cleanly without overflow at ${size.width}x${size.height}',
        (tester) async {
          tester.view.physicalSize = Size(size.width * 2, size.height * 2);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                theme: AppTheme.light(),
                home: const PlacementIntroScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(PlacementIntroScreen), findsOneWidget);
          expect(find.byType(StepFooterButton), findsOneWidget);
          expect(find.text(AppStrings.placementStartButton), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('renders cleanly with 200% text scale without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: PlacementIntroScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PlacementIntroScreen), findsOneWidget);
      expect(find.byType(StepFooterButton), findsOneWidget);
      expect(find.text(AppStrings.placementStartButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly in dark mode without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const PlacementIntroScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PlacementIntroScreen), findsOneWidget);
      expect(find.byType(StepFooterButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

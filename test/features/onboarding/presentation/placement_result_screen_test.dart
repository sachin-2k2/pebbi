import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/domain/language_level.dart';
import 'package:peddi/features/onboarding/domain/level_info.dart';
import 'package:peddi/features/onboarding/domain/placement_result.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/providers/placement_result_notifier.dart';
import 'package:peddi/features/onboarding/presentation/screens/placement_result_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/placement_result/level_option_card.dart';
import 'package:peddi/features/onboarding/presentation/widgets/placement_result/level_picker_sheet.dart';
import 'package:peddi/features/onboarding/presentation/widgets/placement_result/praised_phrases_card.dart';
import 'package:peddi/features/onboarding/presentation/widgets/placement_result/result_chip_row.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  Widget buildTestableScreen({
    PlacementResult? initialResult,
    GoRouter? router,
    double textScale = 1.0,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    final effectiveRouter =
        router ??
        GoRouter(
          initialLocation: '/onboarding/placement-results',
          routes: [
            GoRoute(
              path: '/onboarding/placement-results',
              builder: (context, state) => const PlacementResultScreen(),
            ),
            GoRoute(
              path: '/onboarding/setup/step-6',
              builder: (context, state) =>
                  const Scaffold(body: Text('Placement Intro Step 6')),
            ),
            GoRoute(
              path: '/onboarding/setup/step-7',
              builder: (context, state) =>
                  const Scaffold(body: Text('Setup Step 7 Placeholder')),
            ),
          ],
        );

    return ProviderScope(
      overrides: [
        if (initialResult != null)
          placementResultProvider.overrideWith(
            (ref) => PlacementResultNotifier(initialResult: initialResult),
          ),
      ],
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: MaterialApp.router(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          routerConfig: effectiveRouter,
        ),
      ),
    );
  }

  group('PlacementResultScreen UI & Interaction Tests', () {
    testWidgets(
      'Default state displays mascot, grammar-corrected title, 3 chips, and info cards',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // Mascot with surprised expression
        expect(find.byType(PebbiMascot), findsOneWidget);

        // Title with English grammar fix: "an Expert" instead of "a Expert"
        expect(find.text("You're an Expert learner"), findsOneWidget);
        expect(find.text("You're a Expert learner"), findsNothing);
        expect(find.text(AppStrings.placementResultSubtitle), findsOneWidget);

        // 3 chips: level (Expert), score (8/8 first try), streak (Day 1 streak saved)
        expect(find.byType(ResultChipRow), findsOneWidget);
        expect(find.text('Expert'), findsOneWidget);
        expect(find.text('8/8 first try'), findsOneWidget);
        expect(find.text('Day 1 streak saved'), findsOneWidget);

        // Info card: "What happens now" with sparkle icon
        expect(find.text(AppStrings.whatHappensNowTitle), findsOneWidget);
        expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
        expect(find.text(LevelInfo.expert.whatHappensNowText), findsOneWidget);

        // Phrase card with 3 mint chips
        expect(find.byType(PraisedPhrasesCard), findsOneWidget);
        expect(find.text(AppStrings.alreadySaidRightTitle), findsOneWidget);
        expect(find.text('Un café, por favor'), findsOneWidget);
        expect(find.text('Buenas tardes'), findsOneWidget);
        expect(find.text('Soy de México'), findsOneWidget);

        // Pinned bottom actions
        expect(find.text(AppStrings.startFromHere), findsOneWidget);
        expect(find.text(AppStrings.chooseADifferentLevel), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping "Choose a different level" opens LevelPickerSheet with 3 options',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // Initially picker sheet is not displayed
        expect(find.byType(LevelPickerSheet), findsNothing);
        expect(find.text(AppStrings.chooseADifferentLevel), findsOneWidget);

        // Tap link
        await tester.tap(find.text(AppStrings.chooseADifferentLevel));
        await tester.pumpAndSettle();

        // Picker sheet is open
        expect(find.byType(LevelPickerSheet), findsOneWidget);
        expect(find.byType(LevelOptionCard), findsNWidgets(3));
        expect(find.text('Little'), findsOneWidget);
        expect(find.text('Know a bit'), findsOneWidget);
        expect(
          find.text('Expert'),
          findsNWidgets(2),
        ); // in chip row and in option card

        // Current level (Expert) is selected (has checkmark)
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'Selecting a new level from sheet live updates title, chip, and card 1, and closes sheet',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844) * 2;
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // Open picker sheet
        await tester.tap(find.text(AppStrings.chooseADifferentLevel));
        await tester.pumpAndSettle();

        // Tap "Know a bit"
        final knowABitCard = find.widgetWithText(LevelOptionCard, 'Know a bit');
        await tester.tap(knowABitCard);
        await tester.pumpAndSettle();

        // Sheet closed
        expect(find.byType(LevelPickerSheet), findsNothing);

        // Title updated live
        expect(find.text("You're a Know a bit learner"), findsOneWidget);
        expect(find.text("You're an Expert learner"), findsNothing);

        // Level chip updated live
        expect(find.text('Know a bit'), findsOneWidget);

        // Card 1 updated live
        expect(
          find.text(LevelInfo.knowABit.whatHappensNowText),
          findsOneWidget,
        );

        // Score chip, streak chip, and phrase card stay unchanged
        expect(find.text('8/8 first try'), findsOneWidget);
        expect(find.text('Day 1 streak saved'), findsOneWidget);
        expect(find.text('Un café, por favor'), findsOneWidget);
        expect(find.text(AppStrings.chooseADifferentLevel), findsOneWidget);
      },
    );

    testWidgets('Hides praised phrases card when praisePhrases list is empty', (
      tester,
    ) async {
      const resultNoPhrases = PlacementResult(
        suggestedLevel: LanguageLevel.little,
        chosenLevel: LanguageLevel.little,
        firstTryCorrect: 1,
        totalQuestions: 8,
        praisePhrases: [],
        streakDay: 1,
      );

      await tester.pumpWidget(
        buildTestableScreen(initialResult: resultNoPhrases),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.alreadySaidRightTitle), findsNothing);
    });

    testWidgets('Hides streak chip when streakDay is null', (tester) async {
      const resultNoStreak = PlacementResult(
        suggestedLevel: LanguageLevel.expert,
        chosenLevel: LanguageLevel.expert,
        firstTryCorrect: 8,
        totalQuestions: 8,
        praisePhrases: ['Soy de México'],
        streakDay: null,
      );

      await tester.pumpWidget(
        buildTestableScreen(initialResult: resultNoStreak),
      );
      await tester.pumpAndSettle();

      expect(find.text('Day 1 streak saved'), findsNothing);
      expect(find.text('8/8 first try'), findsOneWidget);
    });

    testWidgets(
      '"Start from here" persists both levels and navigates to Step 7 placeholder',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/onboarding/placement-results',
          routes: [
            GoRoute(
              path: '/onboarding/placement-results',
              builder: (context, state) => const PlacementResultScreen(),
            ),
            GoRoute(
              path: '/onboarding/setup/step-7',
              builder: (context, state) =>
                  const Scaffold(body: Text('Setup Step 7 Placeholder')),
            ),
          ],
        );

        tester.view.physicalSize = const Size(390, 844) * 2;
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late WidgetRef capturedRef;
        await tester.pumpWidget(
          ProviderScope(
            child: Consumer(
              builder: (context, ref, child) {
                capturedRef = ref;
                return MaterialApp.router(
                  theme: AppTheme.light(),
                  routerConfig: router,
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Change level to Little via bottom sheet
        await tester.tap(find.text(AppStrings.chooseADifferentLevel));
        await tester.pumpAndSettle();
        expect(find.byType(LevelPickerSheet), findsOneWidget);

        final littleCard = find.widgetWithText(LevelOptionCard, 'Little');
        await tester.tap(littleCard);
        await tester.pumpAndSettle();
        expect(find.byType(LevelPickerSheet), findsNothing);

        // Tap "Start from here"
        await tester.tap(find.text(AppStrings.startFromHere));
        await tester.pumpAndSettle();

        // Navigated to Step 7
        expect(find.text('Setup Step 7 Placeholder'), findsOneWidget);

        // Stored both suggested and chosen levels in onboardingFlowProvider
        final onboardingState = capturedRef.read(onboardingFlowProvider);
        expect(onboardingState.suggestedLevel, LanguageLevel.expert);
        expect(onboardingState.chosenLevel, LanguageLevel.little);
        expect(onboardingState.selectedLevel, LanguageLevel.little);
      },
    );
  });

  group('PlacementResultScreen Responsive & Overflow Tests', () {
    const testSizes = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(800, 1280), // Android tablet, portrait
      Size(1280, 800), // Android tablet, landscape
      Size(1024, 1366), // iPad Pro
    ];

    for (final size in testSizes) {
      testWidgets(
        'No overflow at ${size.width}x${size.height} at 1.0x & 2.0x scale (picker closed & open)',
        (tester) async {
          for (final scale in [1.0, 2.0]) {
            tester.view.physicalSize = size * 2.0;
            tester.view.devicePixelRatio = 2.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            await tester.pumpWidget(buildTestableScreen(textScale: scale));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);

            // Open picker sheet and verify zero overflow
            final chooseLink = find.text(AppStrings.chooseADifferentLevel);
            if (chooseLink.evaluate().isNotEmpty) {
              await tester.tap(chooseLink);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);

              // Close sheet for next iteration
              final closeBtn = find.byIcon(Icons.close);
              if (closeBtn.evaluate().isNotEmpty) {
                await tester.tap(closeBtn);
                await tester.pumpAndSettle();
              }
            }
          }
        },
      );
    }
  });
}

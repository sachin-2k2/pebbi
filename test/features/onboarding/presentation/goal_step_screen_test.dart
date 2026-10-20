import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/goal_step_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/goal_card.dart';
import 'package:peddi/features/onboarding/presentation/widgets/goal_grid.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_footer_button.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_progress_header.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  Widget buildTestableScreen({
    GoRouter? router,
    double textScale = 1.0,
    ThemeMode themeMode = ThemeMode.light,
    String? initialGoalId,
  }) {
    final effectiveRouter =
        router ??
        GoRouter(
          initialLocation: '/onboarding/setup/step-7',
          routes: [
            GoRoute(
              path: '/onboarding/setup/step-7',
              builder: (context, state) => const GoalStepScreen(),
            ),
            GoRoute(
              path: '/onboarding/setup/step-8',
              builder: (context, state) =>
                  const Scaffold(body: Text('Step 8 Reminder Placeholder')),
            ),
            GoRoute(
              path: '/onboarding/placement-results',
              builder: (context, state) =>
                  const Scaffold(body: Text('Placement Results Screen')),
            ),
          ],
        );

    return ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          if (initialGoalId != null) {
            // Schedule microtask or set during build if needed
            Future.microtask(() {
              ref
                  .read(onboardingFlowProvider.notifier)
                  .setDailyGoal(initialGoalId);
            });
          }
          return MaterialApp.router(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            routerConfig: effectiveRouter,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
          );
        },
      ),
    );
  }

  group('GoalStepScreen UI & Interaction Tests', () {
    testWidgets(
      'Renders header 7/11, title, 4 goal cards, mascot, and enabled Continue button',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // Header 7/11
        final header = tester.widget<StepProgressHeader>(
          find.byType(StepProgressHeader),
        );
        expect(header.currentStep, 7);
        expect(header.totalSteps, 11);
        expect(find.text('7/11'), findsOneWidget);

        final fractionBox = tester.widget<FractionallySizedBox>(
          find.descendant(
            of: find.byType(StepProgressHeader),
            matching: find.byType(FractionallySizedBox),
          ),
        );
        expect(fractionBox.widthFactor, closeTo(7 / 11, 0.01));

        // Title & subtitle without mascot beside title
        expect(find.text(AppStrings.dailyGoalTitle), findsOneWidget);
        expect(find.text(AppStrings.dailyGoalSubtitle), findsOneWidget);

        // 4 Goal Cards
        expect(find.byType(GoalGrid), findsOneWidget);
        expect(find.byType(GoalCard), findsNWidgets(4));
        expect(find.text('Casual'), findsOneWidget);
        expect(find.text('5 min a day'), findsOneWidget);
        expect(find.text('Regular'), findsOneWidget);
        expect(find.text('10 min a day'), findsOneWidget);
        expect(find.text('Serious'), findsOneWidget);
        expect(find.text('15 min a day'), findsOneWidget);
        expect(find.text('Intense'), findsOneWidget);
        expect(find.text('20+ min a day'), findsOneWidget);

        // Regular is preselected by default
        final regularCard = tester.widget<GoalCard>(
          find.widgetWithText(GoalCard, 'Regular'),
        );
        expect(regularCard.isSelected, isTrue);

        final casualCard = tester.widget<GoalCard>(
          find.widgetWithText(GoalCard, 'Casual'),
        );
        expect(casualCard.isSelected, isFalse);

        // Calm smiling mascot present near bottom
        expect(find.byType(PebbiMascot), findsOneWidget);

        // Pinned Continue button enabled
        expect(find.text(AppStrings.continueAction), findsOneWidget);
        final continueBtn = tester.widget<StepFooterButton>(
          find.byType(StepFooterButton),
        );
        expect(continueBtn.isEnabled, isTrue);
      },
    );

    testWidgets(
      'Tapping another card selects it, deselects previous, and stores stable id',
      (tester) async {
        late WidgetRef capturedRef;
        final router = GoRouter(
          initialLocation: '/onboarding/setup/step-7',
          routes: [
            GoRoute(
              path: '/onboarding/setup/step-7',
              builder: (context, state) => const GoalStepScreen(),
            ),
          ],
        );

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

        // Initial state is 'regular'
        expect(
          capturedRef.read(onboardingFlowProvider).selectedGoalId,
          'regular',
        );

        // Tap 'Serious' (15 min)
        await tester.tap(find.widgetWithText(GoalCard, 'Serious'));
        await tester.pumpAndSettle();

        // 'Serious' is now selected, 'Regular' is unselected
        expect(
          capturedRef.read(onboardingFlowProvider).selectedGoalId,
          'serious',
        );
        final seriousCard = tester.widget<GoalCard>(
          find.widgetWithText(GoalCard, 'Serious'),
        );
        expect(seriousCard.isSelected, isTrue);

        final regularCard = tester.widget<GoalCard>(
          find.widgetWithText(GoalCard, 'Regular'),
        );
        expect(regularCard.isSelected, isFalse);

        // Tapping already selected card does nothing
        await tester.tap(find.widgetWithText(GoalCard, 'Serious'));
        await tester.pumpAndSettle();
        expect(
          capturedRef.read(onboardingFlowProvider).selectedGoalId,
          'serious',
        );
      },
    );

    testWidgets('Selection survives back and forward navigation', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/onboarding/setup/step-7',
        routes: [
          GoRoute(
            path: '/onboarding/setup/step-7',
            builder: (context, state) => const GoalStepScreen(),
          ),
          GoRoute(
            path: '/onboarding/setup/step-8',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => context.go('/onboarding/setup/step-7'),
                  child: const Text('Go back to 7'),
                ),
              ),
            ),
          ),
        ],
      );

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

      // Pick Intense (20+ min)
      await tester.tap(find.widgetWithText(GoalCard, 'Intense'));
      await tester.pumpAndSettle();
      expect(
        capturedRef.read(onboardingFlowProvider).selectedGoalId,
        'intense',
      );

      // Tap Continue -> navigates to Step 8
      await tester.tap(find.text(AppStrings.continueAction));
      await tester.pumpAndSettle();
      expect(find.text('Go back to 7'), findsOneWidget);

      // Navigate back to Step 7
      await tester.tap(find.text('Go back to 7'));
      await tester.pumpAndSettle();

      // Intense is still selected
      expect(
        capturedRef.read(onboardingFlowProvider).selectedGoalId,
        'intense',
      );
      final intenseCard = tester.widget<GoalCard>(
        find.widgetWithText(GoalCard, 'Intense'),
      );
      expect(intenseCard.isSelected, isTrue);
    });

    testWidgets('Continue navigates to Step 8 placeholder', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.continueAction));
      await tester.pumpAndSettle();

      expect(find.text('Step 8 Reminder Placeholder'), findsOneWidget);
    });
  });

  group('GoalStepScreen Responsive & Overflow Tests', () {
    const testSizes = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(800, 1280), // Android tablet, portrait
      Size(1280, 800), // Android tablet, landscape
      Size(1024, 1366), // iPad Pro
      Size(700, 400), // Constrained landscape window
    ];

    for (final size in testSizes) {
      testWidgets(
        'Zero overflow at ${size.width}x${size.height} at 1.0x & 2.0x scale (button always visible)',
        (tester) async {
          for (final scale in [1.0, 2.0]) {
            tester.view.physicalSize = size * 2.0;
            tester.view.devicePixelRatio = 2.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            await tester.pumpWidget(buildTestableScreen(textScale: scale));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);

            // Continue button must always be visible and tappable
            expect(find.text(AppStrings.continueAction), findsOneWidget);
            await tester.tap(find.text(AppStrings.continueAction));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  });
}

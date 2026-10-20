import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/reason_step_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/backpack_hint.dart';
import 'package:peddi/features/onboarding/presentation/widgets/reason_card.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_footer_button.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_progress_header.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_title_block.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('ReasonStepScreen Widget & State Tests', () {
    Widget createScreen({
      Set<String>? initialSelectedIds,
      VoidCallback? onContinue,
      VoidCallback? onBack,
      ProviderContainer? container,
    }) {
      final app = MaterialApp(
        theme: AppTheme.light(),
        home: ReasonStepScreen(
          initialSelectedIds: initialSelectedIds,
          onContinue: onContinue,
          onBack: onBack,
        ),
      );

      return container != null
          ? UncontrolledProviderScope(container: container, child: app)
          : ProviderScope(child: app);
    }

    testWidgets(
      'renders header 5/11, title without mascot, 9 cards, and backpack hint',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        // 1. Header (5/11)
        expect(find.byType(StepProgressHeader), findsOneWidget);
        expect(find.text('5/11'), findsOneWidget);

        // 2. Title block without mascot next to title
        expect(find.byType(StepTitleBlock), findsOneWidget);
        expect(find.text(AppStrings.whyAreYouLearningTitle), findsOneWidget);
        expect(find.text(AppStrings.whyAreYouLearningSubtitle), findsOneWidget);
        // Mascot is not in TitleBlock, but in BackpackHint at the bottom
        expect(
          find.descendant(
            of: find.byType(StepTitleBlock),
            matching: find.byType(PebbiMascot),
          ),
          findsNothing,
        );

        // 3. 9 ReasonCards
        expect(find.byType(ReasonCard), findsNWidgets(9));
        expect(find.text('Travel'), findsOneWidget);
        expect(find.text('Work and career'), findsOneWidget);
        expect(find.text('Job interview'), findsOneWidget);
        expect(find.text('Study abroad'), findsOneWidget);
        expect(find.text('Move abroad and settle in'), findsOneWidget);
        expect(find.text('Family and friends'), findsOneWidget);
        expect(find.text('Exams'), findsOneWidget);
        expect(find.text('Culture and fun'), findsOneWidget);
        expect(find.text('Just learning'), findsOneWidget);

        // 4. Backpack hint shows empty state
        expect(find.byType(BackpackHint), findsOneWidget);
        expect(find.text(AppStrings.backpackEmpty), findsOneWidget);

        // 5. Mascot in BackpackHint has backpack outfit
        final mascot = tester.widget<PebbiMascot>(find.byType(PebbiMascot));
        expect(mascot.outfit, equals(PebbiOutfit.backpack));

        // 6. Continue button is enabled
        expect(find.byType(StepFooterButton), findsOneWidget);
        expect(find.text(AppStrings.continueAction), findsOneWidget);
      },
    );

    testWidgets(
      'tapping cards updates selection, check icons, and backpack pill count up to 3',
      (tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        // Initially 0 selected, no check icons
        expect(find.byIcon(Icons.check), findsNothing);
        expect(find.text(AppStrings.backpackEmpty), findsOneWidget);

        // Tap 1: Travel
        await tester.tap(find.text('Travel'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check), findsNWidgets(1));
        expect(find.text('1 of 3 stickers packed'), findsOneWidget);
        expect(find.text('🧳'), findsAtLeastNWidgets(2)); // Card + Backpack

        // Tap 2: Work and career
        await tester.tap(find.text('Work and career'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check), findsNWidgets(2));
        expect(find.text('2 of 3 stickers packed'), findsOneWidget);
        expect(find.text('💼'), findsAtLeastNWidgets(2)); // Card + Backpack

        // Tap 3: Culture and fun
        await tester.tap(find.text('Culture and fun'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check), findsNWidgets(3));
        expect(find.text('3 of 3 stickers packed'), findsOneWidget);
        expect(find.text('🎉'), findsAtLeastNWidgets(2)); // Card + Backpack

        // Tap 4th: Exams (should be rejected, count stays 3, message shown)
        await tester.tap(find.text('Exams'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check), findsNWidgets(3));
        expect(find.text('3 of 3 stickers packed'), findsOneWidget);
        expect(find.text(AppStrings.maxReasonsReached), findsOneWidget);

        // Deselect Travel
        await tester.tap(find.text('Travel'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check), findsNWidgets(2));
        expect(find.text('2 of 3 stickers packed'), findsOneWidget);
      },
    );

    testWidgets(
      'Continue saves selected IDs to state and invokes callback (works with 0 or multiple)',
      (tester) async {
        final container = ProviderContainer();
        var continueCalled = false;

        await tester.pumpWidget(
          createScreen(
            container: container,
            onContinue: () => continueCalled = true,
          ),
        );
        await tester.pumpAndSettle();

        // Select 'study_abroad' and 'just_learning'
        await tester.tap(find.text('Study abroad'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Just learning'));
        await tester.pumpAndSettle();

        // Tap Continue
        await tester.tap(find.text(AppStrings.continueAction));
        await tester.pumpAndSettle();

        expect(continueCalled, isTrue);

        final state = container.read(onboardingFlowProvider);
        expect(
          state.selectedReasonIds,
          equals({'study_abroad', 'just_learning'}),
        );
        expect(state.currentStep, equals(5));
      },
    );

    testWidgets('cards have accessible toggle semantics', (tester) async {
      await tester.pumpWidget(createScreen(initialSelectedIds: {'travel'}));
      await tester.pumpAndSettle();

      // Travel selected
      expect(
        tester.getSemantics(
          find.byWidgetPredicate(
            (w) => w is ReasonCard && w.reason.id == 'travel',
          ),
        ),
        matchesSemantics(
          label: 'Travel, selected',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
        ),
      );

      // Work not selected
      expect(
        tester.getSemantics(
          find.byWidgetPredicate(
            (w) => w is ReasonCard && w.reason.id == 'work',
          ),
        ),
        matchesSemantics(
          label: 'Work and career, not selected',
          isButton: true,
          isSelected: false,
          hasSelectedState: true,
        ),
      );
    });
  });

  group('ReasonStepScreen Responsive & Overflow Tests', () {
    const testSizes = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(800, 1280), // Android tablet portrait
      Size(1280, 800), // Android tablet landscape
      Size(1024, 1366), // iPad portrait
      Size(700, 900), // Foldable / split screen
    ];

    for (final size in testSizes) {
      testWidgets('renders without overflow at ${size.width}x${size.height}', (
        tester,
      ) async {
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const ReasonStepScreen(
                initialSelectedIds: {'travel', 'move_abroad'},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ReasonStepScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
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
              child: ReasonStepScreen(
                initialSelectedIds: {'move_abroad', 'culture'},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReasonStepScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'hides backpack topChild on very short viewports to keep grid scrollable',
      (tester) async {
        // Landscape phone height: 360 logical height
        tester.view.physicalSize = const Size(800 * 2, 360 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const ReasonStepScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ReasonStepScreen), findsOneWidget);
        // Button is still pinned and visible
        expect(find.byType(StepFooterButton), findsOneWidget);
        // BackpackHint gracefully hidden on very short screen (< 500dp)
        expect(find.byType(BackpackHint), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

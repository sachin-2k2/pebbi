import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/notice_banner.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/language_step_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/language_chip.dart';
import 'package:peddi/features/onboarding/presentation/widgets/language_search_field.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_footer_button.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_progress_header.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_title_block.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('LanguageStepScreen Widget & State Tests', () {
    testWidgets('English is selected by default and notice is not shown', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const LanguageStepScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header & Title Block
      expect(find.byType(StepProgressHeader), findsOneWidget);
      expect(find.text('3/11'), findsOneWidget);
      expect(find.byType(StepTitleBlock), findsOneWidget);
      expect(find.byType(PebbiMascot), findsOneWidget);
      expect(find.text(AppStrings.iSpeakTitle), findsOneWidget);

      // 2. Search Field
      expect(find.byType(LanguageSearchField), findsOneWidget);
      expect(find.text(AppStrings.searchLanguagesPlaceholder), findsOneWidget);

      // 3. Language Chips (9 chips total)
      expect(find.byType(LanguageChip), findsNWidgets(9));
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);

      // English has checkmark
      expect(find.byIcon(Icons.check), findsOneWidget);

      // 4. Yellow Notice is NOT shown for English
      expect(find.byType(NoticeBanner), findsNothing);

      // 5. Continue button is enabled
      expect(find.byType(StepFooterButton), findsOneWidget);
      expect(find.text(AppStrings.continueAction), findsOneWidget);
    });

    testWidgets(
      'selecting non-English language reveals yellow notice, switching back hides it',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const LanguageStepScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initially no notice
        expect(find.byType(NoticeBanner), findsNothing);

        // Tap on Arabic chip ('العربية')
        await tester.tap(find.text('العربية'));
        await tester.pumpAndSettle();

        // Notice is now displayed
        expect(find.byType(NoticeBanner), findsOneWidget);
        expect(find.text(AppStrings.translationsPendingNotice), findsOneWidget);

        // Tap back on English
        await tester.tap(find.text('English'));
        await tester.pumpAndSettle();

        // Notice is hidden again
        expect(find.byType(NoticeBanner), findsNothing);
      },
    );

    testWidgets('search filters language list and displays empty state', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const LanguageStepScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Search for "espanol" (ignoring accent)
      await tester.enterText(find.byType(TextField), 'espanol');
      await tester.pumpAndSettle();

      expect(find.text('Español'), findsOneWidget);
      expect(find.text('English'), findsNothing);
      expect(find.byType(LanguageChip), findsOneWidget);

      // Search for nonexistent language
      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noLanguagesFound), findsOneWidget);
      expect(find.byType(LanguageChip), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      expect(find.byType(LanguageChip), findsNWidgets(9));
    });

    testWidgets(
      'Continue stores explanationLanguageCode in state and invokes callback',
      (tester) async {
        final container = ProviderContainer();
        var continueCalled = false;

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light(),
              home: LanguageStepScreen(
                initialCode: 'en',
                onContinue: () => continueCalled = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Select Español
        await tester.tap(find.text('Español'));
        await tester.pumpAndSettle();

        // Tap Continue
        await tester.tap(find.text(AppStrings.continueAction));
        await tester.pumpAndSettle();

        expect(continueCalled, isTrue);

        final state = container.read(onboardingFlowProvider);
        expect(state.explanationLanguageCode, equals('es'));
        expect(state.currentStep, equals(3));
      },
    );
  });

  group('LanguageStepScreen Responsive & Overflow Tests', () {
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
              home: const LanguageStepScreen(initialCode: 'ar'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LanguageStepScreen), findsOneWidget);
        expect(find.byType(NoticeBanner), findsOneWidget);
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
              child: LanguageStepScreen(initialCode: 'es'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LanguageStepScreen), findsOneWidget);
      expect(find.byType(NoticeBanner), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'handles simulated keyboard bottom inset without overflow (body scrolls)',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const MediaQuery(
                data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: 300)),
                child: LanguageStepScreen(initialCode: 'hi'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LanguageStepScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

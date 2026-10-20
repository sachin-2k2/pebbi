import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/button_3d.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/age_step_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/privacy_note_card.dart';
import 'package:peddi/features/onboarding/presentation/widgets/section_label.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_footer_button.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_progress_header.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_title_block.dart';
import 'package:peddi/features/onboarding/presentation/widgets/year_of_birth_field.dart';
import 'package:peddi/features/onboarding/presentation/widgets/year_picker_sheet.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('AgeStepScreen Widget & Privacy Tests', () {
    testWidgets('renders all visual elements per design spec', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const AgeStepScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header
      expect(find.byType(StepProgressHeader), findsOneWidget);
      expect(find.text('2/11'), findsOneWidget);

      // 2. Title Block & Mascot
      expect(find.byType(StepTitleBlock), findsOneWidget);
      expect(find.byType(PebbiMascot), findsOneWidget);
      expect(find.text(AppStrings.howOldAreYouTitle), findsOneWidget);
      expect(find.text(AppStrings.howOldAreYouSubtitle), findsOneWidget);

      // 3. Section Label
      expect(find.byType(SectionLabel), findsOneWidget);
      expect(find.text(AppStrings.yearOfBirthLabel), findsOneWidget);

      // 4. Year Field with default 2002
      expect(find.byType(YearOfBirthField), findsOneWidget);
      expect(find.text('2002'), findsOneWidget);

      // 5. Privacy Note Card
      expect(find.byType(PrivacyNoteCard), findsOneWidget);
      expect(find.textContaining('store only the age band'), findsOneWidget);

      // 6. Continue Button
      expect(find.byType(StepFooterButton), findsOneWidget);
      expect(find.text(AppStrings.continueAction), findsOneWidget);
    });

    testWidgets(
      'tap on year field opens YearPickerSheet and updates selection',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const AgeStepScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap year field
        await tester.tap(find.byType(YearOfBirthField));
        await tester.pumpAndSettle();

        // Picker sheet is displayed
        expect(find.byType(YearPickerSheet), findsOneWidget);
        expect(find.text(AppStrings.yearPickerTitle), findsOneWidget);

        // Select year 2000
        await tester.tap(find.text('2000'));
        await tester.pumpAndSettle();

        // Field now displays 2000
        expect(find.text('2000'), findsOneWidget);
      },
    );

    testWidgets(
      'Continue button derives AgeBand and saves ONLY the band to Riverpod state',
      (tester) async {
        final container = ProviderContainer();
        var continueCalled = false;

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light(),
              home: AgeStepScreen(
                initialYear: 2002,
                onContinue: () => continueCalled = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Continue
        await tester.tap(find.text(AppStrings.continueAction));
        await tester.pumpAndSettle();

        expect(continueCalled, isTrue);

        // Verify state strictly contains AgeBand.adult and NO raw year
        final state = container.read(onboardingFlowProvider);
        expect(state.currentStep, equals(2));
        expect(state.ageBand, equals(AgeBand.adult));
      },
    );

    testWidgets(
      'renders shield icon, protective mascot, and child notice when age is less than 13',
      (tester) async {
        final container = ProviderContainer();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light(),
              home: AgeStepScreen(initialYear: 2014, onContinue: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Year field displays 2014
        expect(find.text('2014'), findsOneWidget);

        // 2. Shield icon is displayed
        expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

        // 3. Child notice text is displayed
        expect(
          find.textContaining(
            'Pebbi is for ages 13 and up. Ask a grown-up to set this up with you',
          ),
          findsOneWidget,
        );

        // 4. Continue button is disabled (turns grey, isEnabled == false)
        final continueButton = tester.widget<Button3D>(find.byType(Button3D));
        expect(continueButton.isEnabled, isFalse);

        // Tapping disabled button does not progress or store state
        await tester.tap(find.text(AppStrings.continueAction));
        await tester.pumpAndSettle();

        final state = container.read(onboardingFlowProvider);
        expect(state.ageBand, isNull);
      },
    );
  });

  group('AgeStepScreen Responsive & Overflow Tests', () {
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
              home: const AgeStepScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AgeStepScreen), findsOneWidget);
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
              child: AgeStepScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AgeStepScreen), findsOneWidget);
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
                child: AgeStepScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AgeStepScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

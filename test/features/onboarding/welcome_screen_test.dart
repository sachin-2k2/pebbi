import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/page_indicator.dart';
import 'package:peddi/features/onboarding/presentation/widgets/welcome_card.dart';
import 'package:peddi/features/onboarding/presentation/widgets/welcome_chip.dart';
import 'package:peddi/features/onboarding/presentation/widgets/welcome_footer_caption.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('WelcomeScreen Pages 1, 2, and 3 Content Tests', () {
    testWidgets('renders page 1 title, subtitle, chips, and chevron button', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light(), home: const WelcomeScreen()),
      );
      await tester.pumpAndSettle();

      // Page 1 Content
      expect(find.text(AppStrings.welcome1Title), findsOneWidget);
      expect(find.text(AppStrings.welcome1Subtitle), findsOneWidget);
      expect(find.text(AppStrings.welcome1Chip1), findsOneWidget);
      expect(find.text(AppStrings.welcome1Chip2), findsOneWidget);
      expect(find.text(AppStrings.welcome1Chip3), findsOneWidget);

      // Widgets
      expect(find.byType(WelcomeCard), findsOneWidget);
      expect(find.byType(WelcomeChip), findsNWidgets(3));
      expect(find.byType(PebbiMascot), findsOneWidget);
      expect(find.byType(PageIndicator), findsOneWidget);
      expect(find.text(AppStrings.skip), findsOneWidget);
      expect(find.text(AppStrings.next), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      // Caption is invisible/not present on Page 1
      expect(find.text(AppStrings.welcome3Caption), findsNothing);
    });

    testWidgets(
      'full flow Page 1 -> Page 2 -> Page 3 works with Next and swiping',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light(), home: const WelcomeScreen()),
        );
        await tester.pumpAndSettle();

        // Initially on Page 1
        expect(find.text(AppStrings.welcome1Title), findsOneWidget);

        // Tap Next -> advance to Page 2
        await tester.tap(find.text(AppStrings.next));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.welcome2Title), findsOneWidget);
        expect(find.text(AppStrings.welcome2Subtitle), findsOneWidget);
        expect(find.text(AppStrings.welcome2Chip1), findsOneWidget);
        expect(find.text(AppStrings.welcome2Chip2), findsOneWidget);
        expect(find.text(AppStrings.welcome2Chip3), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
        expect(find.text(AppStrings.welcome3Caption), findsNothing);

        // Tap Next -> advance to Page 3
        await tester.tap(find.text(AppStrings.next));
        await tester.pumpAndSettle();

        // Now on Page 3
        expect(find.text(AppStrings.welcome3Title), findsOneWidget);
        expect(find.text(AppStrings.welcome3Subtitle), findsOneWidget);
        expect(find.text(AppStrings.welcome3Chip1), findsOneWidget);
        expect(find.text(AppStrings.welcome3Chip2), findsOneWidget);
        expect(find.text(AppStrings.welcome3Chip3), findsOneWidget);

        // Mint Button with "Get started" and NO chevron icon
        expect(find.text(AppStrings.getStarted), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);

        // Footer caption only on Page 3
        expect(find.byType(WelcomeFooterCaption), findsOneWidget);
        expect(find.text(AppStrings.welcome3Caption), findsOneWidget);

        // Swipe back to Page 2
        await tester.drag(find.byType(PageView), const Offset(400.0, 0.0));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.welcome2Title), findsOneWidget);
        expect(find.text(AppStrings.welcome3Title), findsNothing);

        // Swipe back to Page 1
        await tester.drag(find.byType(PageView), const Offset(400.0, 0.0));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.welcome1Title), findsOneWidget);
        expect(find.text(AppStrings.welcome2Title), findsNothing);
      },
    );

    testWidgets(
      'Skip and Get started both trigger the same destination callback',
      (tester) async {
        var completedCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: WelcomeScreen(onComplete: () => completedCount++),
          ),
        );
        await tester.pumpAndSettle();

        // Test Skip from Page 1 triggers onComplete
        await tester.tap(find.text(AppStrings.skip));
        await tester.pumpAndSettle();
        expect(completedCount, 1);

        // Reset and test "Get started" from Page 3 triggers onComplete
        completedCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: WelcomeScreen(onComplete: () => completedCount++),
          ),
        );
        await tester.pumpAndSettle();

        // Advance to Page 2
        await tester.tap(find.text(AppStrings.next));
        await tester.pumpAndSettle();

        // Advance to Page 3
        await tester.tap(find.text(AppStrings.next));
        await tester.pumpAndSettle();

        // Tap "Get started"
        await tester.tap(find.text(AppStrings.getStarted));
        await tester.pumpAndSettle();
        expect(completedCount, 1);
      },
    );
  });

  group('Responsive & No Overflow Tests Across All 3 Pages', () {
    const testViewports = [
      Size(360, 640), // Small Android phone
      Size(390, 844), // iPhone
      Size(800, 1280), // Android tablet, portrait
      Size(1280, 800), // Android tablet, landscape
      Size(1024, 1366), // iPad Pro, portrait
    ];

    const textScales = [1.0, 2.0];

    for (final size in testViewports) {
      for (final textScale in textScales) {
        testWidgets(
          'no overflow at ${size.width.toInt()}x${size.height.toInt()} with text scale $textScale across Pages 1, 2, and 3',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.resetPhysicalSize);

            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                home: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: const WelcomeScreen(),
                ),
              ),
            );
            await tester.pumpAndSettle();

            // Page 1 check
            expect(tester.takeException(), isNull);
            expect(find.text(AppStrings.welcome1Title), findsOneWidget);

            // Page 2 check
            await tester.tap(find.text(AppStrings.next));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
            expect(find.text(AppStrings.welcome2Title), findsOneWidget);

            // Page 3 check
            await tester.tap(find.text(AppStrings.next));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
            expect(find.text(AppStrings.welcome3Title), findsOneWidget);
            expect(find.text(AppStrings.getStarted), findsOneWidget);
            expect(find.text(AppStrings.welcome3Caption), findsOneWidget);
          },
        );
      }
    }
  });
}

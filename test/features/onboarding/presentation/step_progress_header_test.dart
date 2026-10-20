import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_progress_header.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('StepProgressHeader Widget Tests', () {
    testWidgets('renders counter 2/11 and invokes onBack callback on tap', (
      tester,
    ) async {
      var backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: StepProgressHeader(
              currentStep: 2,
              totalSteps: 11,
              onBack: () => backTapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2/11'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      expect(backTapped, isTrue);
    });

    testWidgets('mirrors chevron in RTL directionality', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: StepProgressHeader(currentStep: 2, totalSteps: 11),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('announces accessible semantics for back button and counter', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: StepProgressHeader(currentStep: 2, totalSteps: 11),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(AppStrings.backSemantics), findsOneWidget);
      expect(
        find.bySemanticsLabel(AppStrings.stepProgressSemantics(2, 11)),
        findsOneWidget,
      );
    });
  });
}

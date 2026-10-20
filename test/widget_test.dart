import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/app/app.dart';
import 'package:peddi/app/router.dart';
import 'package:peddi/features/path/presentation/widgets/top_pills.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  testWidgets(
    'PebbiApp smoke test: boots to Welcome, skips to Setup, and navigates Path/Missions',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const ProviderScope(child: PebbiApp()));
      await tester.pumpAndSettle();

      // Verify initial route is WelcomeScreen
      expect(find.text(AppStrings.welcome1Title), findsOneWidget);
      expect(find.text(AppStrings.skip), findsOneWidget);

      // Tap Skip to navigate directly to Step 2 ("How old are you?")
      await tester.tap(find.text(AppStrings.skip));
      await tester.pumpAndSettle();

      // Verify navigated directly to AgeStepScreen
      expect(find.text(AppStrings.howOldAreYouTitle), findsOneWidget);

      // Navigate to PathScreen to test tab navigation
      appRouter.go('/path');
      await tester.pumpAndSettle();

      expect(find.byType(TopPills), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);

      // Tap on Missions tab
      await tester.tap(find.text('Missions'));
      await tester.pumpAndSettle();

      // Verify navigated to MissionsScreen
      expect(find.text(AppStrings.missionsTitle), findsOneWidget);
    },
  );
}

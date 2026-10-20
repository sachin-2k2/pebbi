import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/pebbi_mascot.dart';
import 'package:peddi/core/theme/app_colors.dart';

void main() {
  group('PebbiMascot Widget', () {
    testWidgets('renders cleanly with custom size and accent color', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PebbiMascot(
              size: 64.0,
              accentColor: AppColors.accentMint,
              expression: PebbiExpression.happy,
            ),
          ),
        ),
      );

      expect(find.byType(PebbiMascot), findsOneWidget);

      final size = tester.getSize(find.byType(PebbiMascot));
      expect(size.width, equals(64.0));
      expect(size.height, equals(64.0));
    });

    testWidgets('renders winking expression without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PebbiMascot(expression: PebbiExpression.winking),
          ),
        ),
      );

      expect(find.byType(PebbiMascot), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/button_3d.dart';

void main() {
  group('Button3D Widget', () {
    testWidgets('renders label and handles tap event', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button3D(label: 'Continue', onPressed: () => tapped = true),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('does not trigger callback when disabled', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Button3D(label: 'Locked', onPressed: null)),
        ),
      );

      await tester.tap(find.text('Locked'));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button3D(
              label: 'Play',
              icon: const Icon(Icons.play_arrow, key: Key('play_icon')),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('play_icon')), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
    });

    testWidgets('has correct accessibility semantics', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Button3D(label: 'Start Lesson', onPressed: () {}),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(Button3D)),
        matchesSemantics(
          label: 'Start Lesson',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      handle.dispose();
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/layout/content_width_limiter.dart';
import 'package:peddi/core/layout/responsive_builder.dart';
import 'package:peddi/core/layout/two_pane_layout.dart';
import 'package:peddi/core/layout/window_class.dart';

void main() {
  group('Breakpoints & WindowClass', () {
    test('classifies widths accurately per AGENTS.md §4.2', () {
      expect(windowClassFromWidth(360), WindowClass.compact);
      expect(windowClassFromWidth(599), WindowClass.compact);
      expect(windowClassFromWidth(600), WindowClass.medium);
      expect(windowClassFromWidth(839), WindowClass.medium);
      expect(windowClassFromWidth(840), WindowClass.expanded);
      expect(windowClassFromWidth(1280), WindowClass.expanded);
    });
  });

  group('ResponsiveBuilder Widget', () {
    testWidgets('renders compact widget on phone-sized constraints', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            compact: (context) => const Text('Compact View'),
            medium: (context) => const Text('Medium View'),
            expanded: (context) => const Text('Expanded View'),
          ),
        ),
      );

      expect(find.text('Compact View'), findsOneWidget);
      expect(find.text('Medium View'), findsNothing);
      expect(find.text('Expanded View'), findsNothing);
    });

    testWidgets('renders expanded widget on tablet-sized constraints', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            compact: (context) => const Text('Compact View'),
            medium: (context) => const Text('Medium View'),
            expanded: (context) => const Text('Expanded View'),
          ),
        ),
      );

      expect(find.text('Expanded View'), findsOneWidget);
      expect(find.text('Compact View'), findsNothing);
    });
  });

  group('ContentWidthLimiter Widget', () {
    testWidgets('caps child width without exceeding maxWidth', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: ContentWidthLimiter(
            maxWidth: 600,
            child: SizedBox(width: 1000, height: 200, key: Key('child_box')),
          ),
        ),
      );

      final renderBox =
          tester.renderObject(find.byKey(const Key('child_box'))) as RenderBox;
      expect(renderBox.size.width, equals(600));
    });
  });

  group('TwoPaneLayout Widget', () {
    testWidgets('renders only primary on compact', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: TwoPaneLayout(
            primaryPane: Text('Primary'),
            secondaryPane: Text('Secondary'),
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsNothing);
    });

    testWidgets('renders side-by-side on expanded', (tester) async {
      tester.view.physicalSize = const Size(900, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: TwoPaneLayout(
            primaryPane: Text('Primary'),
            secondaryPane: Text('Secondary'),
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
    });
  });
}

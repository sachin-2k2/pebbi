import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/app/shell/app_nav_rail.dart';
import 'package:peddi/app/shell/app_tab_bar.dart';
import 'package:peddi/core/layout/adaptive_shell.dart';

void main() {
  group('AdaptiveShell Widget', () {
    testWidgets('renders AppTabBar on compact screens', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveShell(
            currentIndex: 0,
            onDestinationSelected: (_) {},
            child: const Text('Body Content'),
          ),
        ),
      );

      expect(find.byType(AppTabBar), findsOneWidget);
      expect(find.byType(AppNavRail), findsNothing);
      expect(find.text('Body Content'), findsOneWidget);
    });

    testWidgets('renders AppNavRail on medium and expanded screens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveShell(
            currentIndex: 0,
            onDestinationSelected: (_) {},
            child: const Text('Body Content'),
          ),
        ),
      );

      expect(find.byType(AppNavRail), findsOneWidget);
      expect(find.byType(AppTabBar), findsNothing);
      expect(find.text('Body Content'), findsOneWidget);
    });
  });
}

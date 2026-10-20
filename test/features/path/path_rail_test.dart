import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/path/domain/path_node.dart';
import 'package:peddi/features/path/presentation/widgets/next_tag.dart';
import 'package:peddi/features/path/presentation/widgets/path_mascot_marker.dart';
import 'package:peddi/features/path/presentation/widgets/path_node_tile.dart';
import 'package:peddi/features/path/presentation/widgets/path_rail.dart';

void main() {
  group('PathNodeTile Widget', () {
    testWidgets('renders node title and next tag when current', (tester) async {
      const node = LessonStopNode(
        id: '1',
        title: 'Say hello',
        state: NodeState.current,
        stopNumber: 1,
        totalStopsInUnit: 3,
        isNext: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: PathNodeTile(node: node)),
          ),
        ),
      );

      expect(find.text('Say hello'), findsOneWidget);
      expect(find.byType(NextTag), findsOneWidget);
    });

    testWidgets('triggers callback when tapped', (tester) async {
      var tapped = false;
      const node = MissionNode(
        id: '2',
        title: 'Order coffee',
        state: NodeState.current,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PathNodeTile(node: node, onTap: () => tapped = true),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Order coffee'));
      expect(tapped, isTrue);
    });
  });

  group('PathRail Widget', () {
    testWidgets(
      'renders list of nodes, companion mascot, and passes tap events',
      (tester) async {
        PathNode? tappedNode;

        const nodes = [
          LessonStopNode(
            id: '1',
            title: 'Lesson 1',
            state: NodeState.done,
            stopNumber: 1,
            totalStopsInUnit: 3,
          ),
          LessonStopNode(
            id: '2',
            title: 'Lesson 2',
            state: NodeState.current,
            stopNumber: 2,
            totalStopsInUnit: 3,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PathRail(nodes: nodes, onNodeTap: (n) => tappedNode = n),
            ),
          ),
        );

        expect(find.text('Lesson 1'), findsOneWidget);
        expect(find.text('Lesson 2'), findsOneWidget);
        expect(find.byType(PathMascotMarker), findsOneWidget);

        await tester.tap(find.text('Lesson 1'));
        expect(tappedNode?.id, equals('1'));
      },
    );
  });
}

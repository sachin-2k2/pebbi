import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/path/domain/path_node.dart';
import 'package:peddi/features/path/domain/unit.dart';
import 'package:peddi/features/path/presentation/widgets/path_scroll_helper.dart';

void main() {
  group('PathScrollHelper Tests', () {
    final testNodes = List.generate(
      7,
      (i) => LessonStopNode(
        id: 'stop-${i + 1}',
        title: 'Stop ${i + 1}',
        state: i < 5
            ? NodeState.done
            : (i == 5 ? NodeState.current : NodeState.locked),
        stopNumber: i + 1,
        totalStopsInUnit: 7,
      ),
    );

    final testUnit = Unit(
      id: 'unit-1',
      unitNumber: 1,
      title: 'Daily Starter',
      trackId: 'daily',
      nodes: testNodes,
    );

    test('returns 0.0 for empty units', () {
      final offset = PathScrollHelper.calculateTargetOffset(
        units: [],
        targetStopId: 'stop-1',
        screenHeight: 844.0,
        isCollapsed: false,
      );
      expect(offset, equals(0.0));
    });

    test('calculates correct offset centering current node (stop 6)', () {
      final offset = PathScrollHelper.calculateTargetOffset(
        units: [testUnit],
        targetStopId: null, // Should find n.isCurrent (stop 6, idx 5)
        screenHeight: 844.0,
        isCollapsed: false,
      );

      // headerOffset (360) + unitHeader (160) + (5 * 148 = 740) = 1260
      // screenHeight * 0.38 = 320.72
      // offset = 1260 - 320.72 = 939.28
      expect(offset, closeTo(939.28, 1.0));
    });

    test('calculates offset for collapsed summary bar', () {
      final offset = PathScrollHelper.calculateTargetOffset(
        units: [testUnit],
        targetStopId: 'stop-6',
        screenHeight: 844.0,
        isCollapsed: true,
      );

      // headerOffset (60) + unitHeader (160) + (5 * 148 = 740) = 960
      // screenHeight * 0.38 = 320.72
      // offset = 960 - 320.72 = 639.28
      expect(offset, closeTo(639.28, 1.0));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/path/domain/node_layout.dart';

void main() {
  group('NodeLayout', () {
    test('returns correct fraction for each node in sequence', () {
      expect(NodeLayout.getFraction(0), 0.50); // Say hello
      expect(NodeLayout.getFraction(1), 0.50); // Nice to meet you
      expect(NodeLayout.getFraction(2), 0.72); // At a café (right)
      expect(NodeLayout.getFraction(3), 0.60); // Review
      expect(NodeLayout.getFraction(4), 0.42); // Mission (left)
      expect(NodeLayout.getFraction(5), 0.32); // Chest (further left)
    });

    test('mirrors horizontal fraction in RTL mode', () {
      expect(NodeLayout.getFraction(0, isRtl: true), 0.50);
      expect(NodeLayout.getFraction(2, isRtl: true), closeTo(0.28, 0.001));
      expect(NodeLayout.getFraction(5, isRtl: true), closeTo(0.68, 0.001));
    });

    test('clamps node diameter between minimum and maximum bounds', () {
      // Extremely narrow rail
      expect(
        NodeLayout.calculateNodeDiameter(200.0),
        NodeLayout.minNodeDiameter,
      );

      // Extremely wide rail
      expect(
        NodeLayout.calculateNodeDiameter(1200.0),
        NodeLayout.maxNodeDiameter,
      );

      // Standard phone width (~400dp -> 400 * 0.16 = 64)
      expect(
        NodeLayout.calculateNodeDiameter(400.0),
        NodeLayout.minNodeDiameter,
      );
    });
  });
}

/// Pure Dart geometry calculator for the winding path rail nodes.
///
/// Follows AGENTS.md §2.2: Pure Dart model with zero Flutter imports.
class NodeLayout {
  const NodeLayout();

  /// Estimated horizontal fraction anchors across the available rail width (0.0 to 1.0).
  ///
  /// TODO(question: ask the designer for the exact bezier mathematical curve or anchors).
  static const List<double> nodeFractions = [
    0.50, // 0: Say hello (center)
    0.50, // 1: Nice to meet you (center)
    0.72, // 2: At a café (shifted right)
    0.60, // 3: Review (slightly right)
    0.42, // 4: Mission (shifted left)
    0.32, // 5: Chest (further left)
  ];

  /// Minimum and maximum node sizes (clamped for responsive scaling).
  static const double minNodeDiameter = 64.0;
  static const double maxNodeDiameter = 76.0;

  /// Returns the horizontal position fraction for the given node [index] (0.0 = left, 1.0 = right).
  ///
  /// Automatically mirrors for RTL (right-to-left) reading direction.
  static double getFraction(int index, {bool isRtl = false}) {
    final base = nodeFractions[index % nodeFractions.length];
    return isRtl ? (1.0 - base) : base;
  }

  /// Calculates the clamped node diameter based on available rail width.
  static double calculateNodeDiameter(double availableWidth) {
    final computed = availableWidth * 0.16;
    return computed.clamp(minNodeDiameter, maxNodeDiameter);
  }

  /// Computes the horizontal center pixel coordinate given [availableWidth] and [fraction].
  static double computeCenterX(double availableWidth, double fraction) {
    return availableWidth * fraction;
  }
}

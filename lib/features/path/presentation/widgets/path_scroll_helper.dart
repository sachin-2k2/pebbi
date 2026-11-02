import '../../domain/unit.dart';

/// Pure calculation helper for Candy Crush style path map centering.
///
/// Follows AGENTS.md §3 (<150 lines) with pure calculation logic.
class PathScrollHelper {
  /// Calculates the vertical scroll offset to center the active level node.
  static double calculateTargetOffset({
    required List<Unit> units,
    required String? targetStopId,
    required double screenHeight,
    required bool isCollapsed,
  }) {
    if (units.isEmpty) return 0.0;

    // Header offset inside ListView (ContinueCard, DueStrip, AdBanner)
    final headerOffset = isCollapsed ? 60.0 : 360.0;
    double accumulatedY = headerOffset;

    for (final unit in units) {
      const unitHeaderHeight = 160.0;
      final idx = unit.nodes.indexWhere(
        (n) =>
            (targetStopId != null && n.id == targetStopId) ||
            (targetStopId == null && n.isCurrent),
      );

      if (idx != -1) {
        final nodeY = accumulatedY + unitHeaderHeight + (idx * 148.0);
        // Center the active node at ~38% from the top of the viewport
        final offset = nodeY - (screenHeight * 0.38);
        return offset.clamp(0.0, 50000.0);
      }

      accumulatedY +=
          unitHeaderHeight +
          (unit.nodes.length * 148.0) +
          (unit.isFreeUnit && unit.isCompleted ? 80.0 : 0.0) +
          16.0;
    }

    return 0.0;
  }
}


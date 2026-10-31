import 'package:flutter/material.dart';
import 'path_mascot_marker.dart';

/// Animated positioned layer rendering Pebbi beside the active or moving path node.
///
/// Follows AGENTS.md §3: Extracted widget keeping [PathRail] under 150 lines.
class PathRailMascotLayer extends StatelessWidget {
  const PathRailMascotLayer({
    super.key,
    required this.centers,
    required this.activeIndex,
  });

  final List<Offset> centers;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    if (activeIndex == -1 || activeIndex >= centers.length) {
      return const SizedBox.shrink();
    }
    final center = centers[activeIndex];
    final isOnRight = center.dx < 120.0;
    return AnimatedPositioned(
      key: const ValueKey('path_mascot_pebbi'),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
      left: isOnRight ? center.dx + 44.0 : center.dx - 88.0,
      top: center.dy - 20.0,
      child: PathMascotMarker(isOnRight: isOnRight),
    );
  }
}


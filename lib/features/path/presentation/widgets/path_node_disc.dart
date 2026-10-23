import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/path_node_data.dart';

/// 3D circular disc widget for a path stop.
class PathNodeDisc extends StatelessWidget {
  const PathNodeDisc({
    super.key,
    required this.node,
    this.diameter = 68.0,
    this.depth = 6.0,
  });

  final PathNodeData node;
  final double diameter;
  final double depth;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = _resolveColors(node, palette);
    final icon = _resolveIcon(node);

    return SizedBox(
      width: diameter,
      height: diameter + depth,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Bottom 3D Depth Layer
          Positioned(
            top: depth,
            child: Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                color: colors.depth,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Interactive Face Layer
          Positioned(
            top: 0,
            child: Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                color: colors.face,
                shape: BoxShape.circle,
                boxShadow: palette.cardShadow,
              ),
              child: Center(
                child: Icon(icon, color: colors.icon, size: diameter * 0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static ({Color face, Color depth, Color icon}) _resolveColors(
    PathNodeData node,
    AppPalette palette,
  ) {
    if (node.isLocked) {
      return (
        face: palette.nodeLocked,
        depth: palette.nodeLockedDepth,
        icon: palette.disabledText,
      );
    }
    if (node.type == PathNodeType.chest) {
      return (
        face: palette.gold,
        depth: palette.goldDepth,
        icon: palette.textOnBrand,
      );
    }
    if (node.isCompleted) {
      return (
        face: palette.nodeDone,
        depth: palette.nodeDoneDepth,
        icon: palette.textOnBrand,
      );
    }
    return (
      face: palette.nodeCurrent,
      depth: palette.nodeCurrentDepth,
      icon: palette.textOnBrand,
    );
  }

  static IconData _resolveIcon(PathNodeData node) {
    if (node.isLocked) return Icons.lock_rounded;
    switch (node.type) {
      case PathNodeType.lesson:
        return node.isCompleted ? Icons.check_rounded : Icons.star_rounded;
      case PathNodeType.review:
        return Icons.sync_rounded;
      case PathNodeType.mission:
        return Icons.forum_rounded;
      case PathNodeType.chest:
        return Icons.card_giftcard_rounded;
    }
  }
}

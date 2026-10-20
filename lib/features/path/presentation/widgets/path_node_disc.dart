import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
    final colors = _resolveColors(node);
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
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
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
  ) {
    if (node.isLocked) {
      return (
        face: AppColors.disabled,
        depth: AppColors.disabledDepth,
        icon: AppColors.disabledText,
      );
    }
    if (node.type == PathNodeType.chest) {
      return (
        face: AppColors.starGold,
        depth: AppColors.goldDepth,
        icon: Colors.white,
      );
    }
    if (node.isCompleted) {
      return (
        face: AppColors.mint,
        depth: AppColors.mintDepth,
        icon: Colors.white,
      );
    }
    return (
      face: AppColors.brandPurple,
      depth: AppColors.brandPurpleDepth,
      icon: Colors.white,
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

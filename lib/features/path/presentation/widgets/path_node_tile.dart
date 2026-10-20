import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/path_node.dart';
import 'current_node_ring.dart';
import 'next_tag.dart';
import 'node_shape.dart';

/// Single interactive path node with title, 3D shape, ring, and semantics.
class PathNodeTile extends StatelessWidget {
  const PathNodeTile({super.key, required this.node, this.onTap});

  final PathNode node;
  final VoidCallback? onTap;

  void _handleTap() {
    HapticFeedback.lightImpact();
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final visual = _resolveVisual(node);
    final isNext =
        node.isCurrent ||
        (node is LessonStopNode && (node as LessonStopNode).isNext);

    return Semantics(
      button: true,
      label: '${node.title}, ${node.state.name}',
      hint: node.isLocked ? 'Locked stop' : 'Tap to open',
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (isNext) const Positioned(top: -24.0, child: NextTag()),
                if (node.isCurrent)
                  CurrentNodeRing(
                    diameter: 68.0,
                    child: NodeShape(
                      shape: visual.shape,
                      faceColor: visual.faceColor,
                      depthColor: visual.depthColor,
                      child: Icon(
                        visual.icon,
                        color: visual.iconColor,
                        size: 28.0,
                      ),
                    ),
                  )
                else
                  NodeShape(
                    shape: visual.shape,
                    faceColor: visual.faceColor,
                    depthColor: visual.depthColor,
                    child: Icon(
                      visual.icon,
                      color: visual.iconColor,
                      size: 28.0,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              constraints: const BoxConstraints(maxWidth: 110.0),
              child: Text(
                node.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMedium.copyWith(
                  color: node.isLocked
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  fontWeight: node.isCurrent
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static ({
    NodeShapeType shape,
    Color faceColor,
    Color depthColor,
    Color iconColor,
    IconData icon,
  })
  _resolveVisual(PathNode node) {
    if (node.isLocked) {
      return (
        shape: node is ChestNode
            ? NodeShapeType.roundedSquare
            : (node is MissionNode
                  ? NodeShapeType.hexagon
                  : NodeShapeType.circle),
        faceColor: AppColors.disabled,
        depthColor: AppColors.disabledDepth,
        iconColor: AppColors.disabledText,
        icon: Icons.lock_rounded,
      );
    }

    if (node is ChestNode) {
      return (
        shape: NodeShapeType.roundedSquare,
        faceColor: AppColors.starGold,
        depthColor: AppColors.goldDepth,
        iconColor: Colors.white,
        icon: Icons.card_giftcard_rounded,
      );
    }

    if (node.isDone) {
      return (
        shape: node is MissionNode
            ? NodeShapeType.hexagon
            : NodeShapeType.circle,
        faceColor: AppColors.mint,
        depthColor: AppColors.mintDepth,
        iconColor: Colors.white,
        icon: Icons.check_rounded,
      );
    }

    final shape = node is MissionNode
        ? NodeShapeType.hexagon
        : NodeShapeType.circle;
    final icon = node is MissionNode
        ? Icons.forum_rounded
        : (node is ReviewNode ? Icons.sync_rounded : Icons.star_rounded);

    return (
      shape: shape,
      faceColor: AppColors.brandPurple,
      depthColor: AppColors.brandPurpleDepth,
      iconColor: Colors.white,
      icon: icon,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_palette.dart';
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
    final palette = context.palette;
    final visual = _resolveVisual(node, palette);
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: KeyedSubtree(
                    key: ValueKey('${node.id}_${node.state.name}'),
                    child: node.isCurrent
                        ? CurrentNodeRing(
                            diameter: 68.0,
                            child: _NodeVisualShape(visual: visual),
                          )
                        : _NodeVisualShape(visual: visual),
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
                      ? palette.textTertiary
                      : palette.textPrimary,
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

  static _Visual _resolveVisual(PathNode node, AppPalette palette) {
    if (node.isLocked) {
      final shape = node is ChestNode
          ? NodeShapeType.roundedSquare
          : (node is MissionNode ? NodeShapeType.hexagon : NodeShapeType.circle);
      return _Visual(
        shape: shape,
        faceColor: palette.nodeLocked,
        depthColor: palette.nodeLockedDepth,
        iconColor: palette.disabledText,
        icon: Icons.lock_rounded,
      );
    }
    if (node is ChestNode) {
      return _Visual(
        shape: NodeShapeType.roundedSquare,
        faceColor: palette.gold,
        depthColor: palette.goldDepth,
        iconColor: palette.textOnBrand,
        icon: Icons.card_giftcard_rounded,
      );
    }
    if (node.isDone) {
      return _Visual(
        shape: node is MissionNode ? NodeShapeType.hexagon : NodeShapeType.circle,
        faceColor: palette.nodeDone,
        depthColor: palette.nodeDoneDepth,
        iconColor: palette.textOnBrand,
        icon: Icons.check_rounded,
      );
    }
    final shape =
        node is MissionNode ? NodeShapeType.hexagon : NodeShapeType.circle;
    final icon = node is MissionNode
        ? Icons.forum_rounded
        : (node is ReviewNode ? Icons.sync_rounded : Icons.star_rounded);
    return _Visual(
      shape: shape,
      faceColor: palette.nodeCurrent,
      depthColor: palette.nodeCurrentDepth,
      iconColor: palette.textOnBrand,
      icon: icon,
    );
  }
}

class _Visual {
  const _Visual({
    required this.shape,
    required this.faceColor,
    required this.depthColor,
    required this.iconColor,
    required this.icon,
  });
  final NodeShapeType shape;
  final Color faceColor;
  final Color depthColor;
  final Color iconColor;
  final IconData icon;
}

class _NodeVisualShape extends StatelessWidget {
  const _NodeVisualShape({required this.visual});

  final _Visual visual;

  @override
  Widget build(BuildContext context) {
    return NodeShape(
      shape: visual.shape,
      faceColor: visual.faceColor,
      depthColor: visual.depthColor,
      child: Icon(visual.icon, color: visual.iconColor, size: 28.0),
    );
  }
}

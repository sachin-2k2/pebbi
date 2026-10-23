import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/path_node_data.dart';
import 'path_node_disc.dart';

/// Single interactive path node with title and mascot companion.
class PathNode extends StatelessWidget {
  const PathNode({
    super.key,
    required this.node,
    this.onTap,
    this.showMascot = false,
  });

  final PathNodeData node;
  final VoidCallback? onTap;
  final bool showMascot;

  void _handleTap() {
    HapticFeedback.selectionClick();
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              PathNodeDisc(node: node),
              // Pebbi Mascot sitting beside the current node
              if (showMascot)
                const Positioned(
                  left: -48.0,
                  bottom: 0,
                  child: PebbiMascot(
                    size: 44.0,
                    expression: PebbiExpression.happy,
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
                fontWeight: node.isCurrent ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

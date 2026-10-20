import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';

/// Companion mascot standing beside the active path node.
///
/// Follows AGENTS.md §8: supports RTL mirroring and size scaling.
class PathMascotMarker extends StatelessWidget {
  const PathMascotMarker({
    super.key,
    this.size = 46.0,
    this.expression = PebbiExpression.happy,
    this.isOnRight = false,
  });

  final double size;
  final PebbiExpression expression;
  final bool isOnRight;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final flipHorizontal = isOnRight != isRtl;

    Widget mascot = PebbiMascot(size: size, expression: expression);

    if (flipHorizontal) {
      mascot = Transform.scale(scaleX: -1.0, child: mascot);
    }

    return Semantics(label: 'Pebbi cheering you on', child: mascot);
  }
}

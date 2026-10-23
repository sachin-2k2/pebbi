import 'package:flutter/material.dart';
import 'splash_decoration_config.dart';

/// Single floating decorative item (emoji placeholder or asset icon).
///
/// Follows User Rules & Accessibility:
/// - Excluded from screen readers (ExcludeSemantics)
/// - Single widget that can switch between emoji placeholders and image assets
/// - TODO(question): replace Unicode emoji with custom PNG/SVG assets when provided.
class SplashDecorationItem extends StatelessWidget {
  const SplashDecorationItem({
    super.key,
    required this.item,
    this.opacity = 1.0,
    this.driftOffset = Offset.zero,
  });

  final SplashDecorationItemData item;
  final double opacity;
  final Offset driftOffset;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0.0) return const SizedBox.shrink();

    return ExcludeSemantics(
      child: Transform.translate(
        offset: driftOffset,
        child: Opacity(
          opacity: opacity,
          child: Text(
            item.emoji,
            style: TextStyle(fontSize: item.size),
            textScaler: TextScaler.noScaling,
          ),
        ),
      ),
    );
  }
}

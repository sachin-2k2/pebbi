import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable rounded-square tinted tile for icons, emojis, or small avatars.
///
/// Follows AGENTS.md §4.6 (flexible sizing, tokens) and §8:
/// - Reused across Home ContinueCard, Missions list/hero, and Review cards.
/// - Clamped between minimum and maximum sizes (default 40dp..52dp).
/// - Excludes child semantics by default so parent buttons control the label.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.tintLavender,
    this.size = 48.0,
    this.minSize = 40.0,
    this.maxSize = 52.0,
    this.borderRadius = AppSpacing.radiusIconTile,
    this.excludeSemantics = true,
  });

  /// Factory constructor for text emoji icon tiles.
  factory IconTile.emoji(
    String emoji, {
    Key? key,
    Color backgroundColor = AppColors.tintPeach,
    double size = 48.0,
    double fontSize = 24.0,
  }) {
    return IconTile(
      key: key,
      backgroundColor: backgroundColor,
      size: size,
      child: Text(
        emoji,
        style: TextStyle(fontSize: fontSize),
        textScaler: TextScaler.noScaling,
      ),
    );
  }

  /// Inner icon or decorative widget.
  final Widget child;

  /// Background tint color.
  final Color backgroundColor;

  /// Nominal size (width and height).
  final double size;

  /// Minimum clamped size.
  final double minSize;

  /// Maximum clamped size.
  final double maxSize;

  /// Border radius of the tile.
  final double borderRadius;

  /// Whether to exclude child semantics (default true).
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size.clamp(minSize, maxSize);

    Widget content = Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: child,
    );

    if (excludeSemantics) {
      content = ExcludeSemantics(child: content);
    }

    return content;
  }
}

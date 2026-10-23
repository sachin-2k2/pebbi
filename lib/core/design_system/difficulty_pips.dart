import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';

/// Segmented difficulty rating indicator.
///
/// Follows AGENTS.md §3 & §8:
/// - Reusable in design system (e.g. Missions list in coral, Onboarding in purple).
/// - Configurable filled count, total segments, and colors.
/// - Accessible semantics announcing rating.
class DifficultyPips extends StatelessWidget {
  const DifficultyPips({
    super.key,
    required this.filledCount,
    this.totalCount = 3,
    this.filledColor,
    this.emptyColor,
    this.pipWidth = 14.0,
    this.pipHeight = 4.0,
    this.excludeSemantics = false,
  });

  /// Number of active/filled pips (e.g. 1, 2, or 3).
  final int filledCount;

  /// Total number of pips (default 3).
  final int totalCount;

  /// Color used for active segments.
  final Color? filledColor;

  /// Color used for inactive segments.
  final Color? emptyColor;

  /// Width of each segment.
  final double pipWidth;

  /// Height of each segment.
  final double pipHeight;

  /// Whether to exclude semantics (used when parent tile provides consolidated label).
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final activeColor = filledColor ?? palette.brand;
    final inactiveColor = emptyColor ?? palette.disabledFill;
    final effectiveFilled = filledCount.clamp(0, totalCount);

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < totalCount; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.xs),
          Container(
            width: pipWidth,
            height: pipHeight,
            decoration: BoxDecoration(
              color: i < effectiveFilled ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: i < effectiveFilled
                  ? null
                  : Border.all(color: palette.outline, width: 0.8),
            ),
          ),
        ],
      ],
    );

    if (excludeSemantics) {
      return ExcludeSemantics(child: content);
    }

    return Semantics(
      label: AppStrings.difficultyPipsSemantics(effectiveFilled, totalCount),
      child: content,
    );
  }
}

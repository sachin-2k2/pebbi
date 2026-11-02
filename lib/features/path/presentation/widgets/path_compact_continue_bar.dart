import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Compact 48dp action bar for the path screen when summary is minimized.
///
/// Follows AGENTS.md §3 (<150 lines) and provides Candy Crush map immersion:
/// - Next lesson title and duration.
/// - Direct play button.
/// - Quick review pill if phrases are due.
/// - Expand toggle to reveal full summary cards.
class PathCompactContinueBar extends StatelessWidget {
  const PathCompactContinueBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPlayPressed,
    required this.onExpandPressed,
    this.dueCount = 0,
    this.onReviewPressed,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPlayPressed;
  final VoidCallback onExpandPressed;
  final int dueCount;
  final VoidCallback? onReviewPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: palette.outline),
          boxShadow: palette.cardShadow,
        ),
        child: Row(
          children: [
            // Mascot avatar
            Container(
              width: 34.0,
              height: 34.0,
              decoration: BoxDecoration(
                color: palette.tintLavender,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Center(
                child: PebbiMascot(size: 24.0, accentColor: palette.brand),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Next lesson title
            Expanded(
              child: InkWell(
                onTap: onPlayPressed,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: palette.textMuted,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Due pill if items due
            if (dueCount > 0 && onReviewPressed != null)
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: InkWell(
                  onTap: onReviewPressed,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: palette.tintLavender,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(
                      '$dueCount due',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        color: palette.brandText,
                      ),
                    ),
                  ),
                ),
              ),

            // Play button
            IconButton(
              iconSize: 26.0,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
              icon: Icon(Icons.play_circle_fill_rounded, color: palette.mint),
              onPressed: onPlayPressed,
              tooltip: 'Start lesson',
            ),

            // Expand button
            IconButton(
              iconSize: 22.0,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32.0, minHeight: 32.0),
              icon: Icon(Icons.expand_more_rounded, color: palette.textMuted),
              onPressed: onExpandPressed,
              tooltip: 'Show summary cards',
            ),
          ],
        ),
      ),
    );
  }
}


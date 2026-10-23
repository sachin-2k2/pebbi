import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// "Phrases due" status strip linking to Review per design spec §5 & §8.
///
/// Distinguishes between 0 phrases, 0 due (strong), and N due.
/// Wraps text to up to 2 lines so phrases are never truncated by ellipsis.
class DueStrip extends StatelessWidget {
  const DueStrip({
    super.key,
    required this.dueCount,
    required this.hasPhrases,
    required this.onReviewTap,
  });

  final int dueCount;
  final bool hasPhrases;
  final VoidCallback onReviewTap;

  String get _message {
    if (!hasPhrases) {
      return AppStrings.dueStripZeroPhrases;
    } else if (dueCount == 0) {
      return AppStrings.dueStripNothingDue;
    } else {
      return '$dueCount ${dueCount == 1 ? "phrase" : "phrases"} ${AppStrings.dueStripCountDue}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: palette.outline),
        boxShadow: palette.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sparkle Icon Tile
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: palette.tintLavender,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: palette.brand,
              size: 16.0,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Message (wrapped up to 2 lines without clipping)
          Expanded(
            child: Text(
              _message,
              style: AppTypography.bodyMedium.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Review Link Button
          TextButton(
            onPressed: onReviewTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: const Size(48.0, 48.0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AppStrings.dueStripReviewAction,
              style: AppTypography.labelMedium.copyWith(
                color: palette.brandText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

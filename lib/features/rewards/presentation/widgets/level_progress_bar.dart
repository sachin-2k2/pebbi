import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Level progress indicator with level captions and smooth progress bar.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.1.
class LevelProgressBar extends StatelessWidget {
  const LevelProgressBar({
    super.key,
    required this.level,
    required this.starsInLevel,
    required this.starsForNextLevel,
    required this.progressRatio,
  });

  final int level;
  final int starsInLevel;
  final int? starsForNextLevel;
  final double progressRatio;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final captionColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final trackColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.tintLavender.withValues(alpha: 0.8);

    final leftCaption = AppStrings.rewardsLevelCaption(level);
    final rightCaption = starsForNextLevel != null
        ? AppStrings.rewardsNextLevelCaption(level + 1, starsForNextLevel!)
        : AppStrings.rewardsTopLevel;

    return Semantics(
      label: AppStrings.rewardsLevelProgressSemantics(
        level,
        starsInLevel,
        starsForNextLevel,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: 2.0,
            children: [
              Text(
                leftCaption,
                style: AppTypography.caption.copyWith(
                  color: captionColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.0,
                ),
              ),
              Text(
                rightCaption,
                style: AppTypography.caption.copyWith(
                  color: captionColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 2.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 8.0,
              backgroundColor: trackColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.brandPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

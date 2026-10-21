import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Card showing current streak count, active days, freezes, and calendar shortcut.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.6 (48dp tap target).
class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.streakDays,
    required this.activeDaysCount,
    required this.freezesReady,
    required this.onCalendarPressed,
  });

  final int streakDays;
  final int activeDaysCount;
  final int freezesReady;
  final VoidCallback onCalendarPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;
    final pillBg = isDark
        ? AppColors.darkRewardsPillCoralBackground
        : AppColors.rewardsPillCoralBackground;
    final pillText = isDark
        ? AppColors.darkRewardsPillCoralText
        : AppColors.rewardsPillCoralText;

    return Semantics(
      label: AppStrings.rewardsStreakSemantics(
        streakDays,
        activeDaysCount,
        freezesReady,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + 2.0,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: border, width: 1.0),
          boxShadow: isDark ? null : AppSpacing.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.accentOrange,
              size: 32.0,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.rewardsStreakTitle(streakDays),
                    style: AppTypography.cardTitle.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    AppStrings.rewardsStreakSubtitle(
                      activeDaysCount,
                      freezesReady,
                    ),
                    style: AppTypography.caption.copyWith(
                      color: subtitleColor,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Semantics(
              button: true,
              label: AppStrings.rewardsCalendarPill,
              child: InkWell(
                onTap: onCalendarPressed,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 48.0,
                    minHeight: 48.0,
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 4.0,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                    ),
                    child: Text(
                      AppStrings.rewardsCalendarPill,
                      style: AppTypography.caption.copyWith(
                        color: pillText,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

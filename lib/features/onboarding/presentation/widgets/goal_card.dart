import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/daily_goal_info.dart';

/// Selectable goal card representing a daily time commitment tier.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// 48dp minimum tap target, centered vertical content, accessible semantics,
/// non-colour selection cues (thicker 2.0 border & typography weight emphasis).
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.isSelected,
    required this.onTap,
    required this.index,
    required this.total,
  });

  final DailyGoalInfo goal;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isSelected
        ? (isDark ? AppColors.darkSurfaceVariant : AppColors.tintLavender)
        : (isDark ? AppColors.darkSurface : AppColors.surface);
    final border = isSelected
        ? AppColors.brandPurple
        : (isDark ? AppColors.darkBorder : AppColors.borderLight);
    final borderWidth = isSelected ? 2.0 : 1.0;
    final nameColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final captionColor = isSelected
        ? (isDark ? AppColors.brandPurpleLight : AppColors.brandPurple)
        : (isDark ? AppColors.darkTextMuted : AppColors.textMuted);

    return Semantics(
      button: true,
      selected: isSelected,
      label: AppStrings.dailyGoalCardSemantics(
        name: goal.name,
        minutes: goal.minutes,
        index: index,
        total: total,
        isSelected: isSelected,
        isOpenEnded: goal.isOpenEnded,
      ),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: border, width: borderWidth),
              boxShadow: isDark || isSelected ? null : AppSpacing.cardShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Text(
                    goal.emoji,
                    style: const TextStyle(fontSize: 32.0),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  goal.name,
                  textAlign: TextAlign.center,
                  style: AppTypography.screenTitle.copyWith(
                    fontSize: 16.0,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                    color: nameColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  goal.caption,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: captionColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

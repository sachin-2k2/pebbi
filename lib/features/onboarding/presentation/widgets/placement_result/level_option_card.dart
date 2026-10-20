import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/level_info.dart';

/// Single selectable level card for the inline placement level picker.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// 48dp minimum tap target, distinct selected styling with purple border & checkmark.
class LevelOptionCard extends StatelessWidget {
  const LevelOptionCard({
    super.key,
    required this.levelInfo,
    required this.isSelected,
    required this.onTap,
    required this.index,
    required this.total,
  });

  final LevelInfo levelInfo;
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
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final descColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Semantics(
      button: true,
      selected: isSelected,
      label: AppStrings.levelOptionSemantics(
        name: levelInfo.name,
        description: levelInfo.description,
        index: index,
        total: total,
        isSelected: isSelected,
      ),
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
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: border, width: isSelected ? 1.5 : 1.0),
              boxShadow: isDark || isSelected ? null : AppSpacing.cardShadow,
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Text(
                    levelInfo.emoji,
                    style: const TextStyle(fontSize: 26.0),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        levelInfo.name,
                        style: AppTypography.cardTitle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        levelInfo.description,
                        style: AppTypography.caption.copyWith(color: descColor),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(left: AppSpacing.sm),
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.brandPurple,
                      size: 22.0,
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

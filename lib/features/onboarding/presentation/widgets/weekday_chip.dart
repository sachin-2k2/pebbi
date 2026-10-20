import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/weekday.dart';

/// Selectable toggle chip for an individual weekday (M, T, W, T, F, S, S).
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// min 48dp touch target, accessible semantics, non-colour cue (2.0 vs 1.0 border).
class WeekdayChip extends StatelessWidget {
  const WeekdayChip({
    super.key,
    required this.weekday,
    required this.isSelected,
    required this.onTap,
  });

  final Weekday weekday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isSelected
        ? AppColors.brandPurple
        : (isDark ? AppColors.darkBorder : AppColors.borderLight);
    final borderWidth = isSelected ? 2.0 : 1.0;
    final textColor = isSelected
        ? (isDark ? AppColors.brandPurpleLight : AppColors.brandPurple)
        : (isDark ? AppColors.darkTextMuted : AppColors.textMuted);

    return Semantics(
      button: true,
      selected: isSelected,
      label: AppStrings.weekdayChipSemantics(
        dayName: weekday.fullName,
        isSelected: isSelected,
      ),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
            ),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: border, width: borderWidth),
                boxShadow: isDark || isSelected ? null : AppSpacing.cardShadow,
              ),
              child: Text(
                weekday.shortLetter,
                textAlign: TextAlign.center,
                style: AppTypography.screenTitle.copyWith(
                  fontSize: 16.0,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

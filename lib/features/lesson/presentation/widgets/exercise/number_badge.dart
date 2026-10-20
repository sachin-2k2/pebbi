import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Lavender rounded badge displaying an option index (1, 2, 3).
///
/// Follows AGENTS.md §3 & §4: under 100 lines, excludes semantics to avoid
/// double announcements, stays top-aligned and never stretches on multi-line text.
class NumberBadge extends StatelessWidget {
  const NumberBadge({super.key, required this.number, this.isSelected = false});

  final int number;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark
        ? AppColors.darkSurfaceVariant
        : (isSelected
              ? AppColors.brandPurple.withValues(alpha: 0.15)
              : const Color(0xFFEDE9FE));
    final fg = isDark ? AppColors.brandPurpleLight : AppColors.brandPurple;

    return ExcludeSemantics(
      child: Container(
        width: 28.0,
        height: 28.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(
          '$number',
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: fg,
            fontSize: 14.0,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

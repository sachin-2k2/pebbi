import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Single white stat card displaying a bold value above a muted label.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.6.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final valueColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final labelColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Semantics(
      label: '$value $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: border, width: 1.0),
          boxShadow: isDark ? null : AppSpacing.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: AppTypography.screenTitle.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w800,
                fontSize: 22.0,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: labelColor,
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

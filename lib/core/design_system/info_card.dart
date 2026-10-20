import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Reusable rounded surface card displaying a bold title and muted body text.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// flexible sizing, token-based styling, dark mode aware.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.body,
    this.leadingIcon,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
  });

  final String title;
  final String body;
  final Widget? leadingIcon;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final bodyColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border, width: 1.0),
        boxShadow: isDark ? null : AppSpacing.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null)
            Row(
              children: [
                leadingIcon!,
                const SizedBox(width: AppSpacing.xs + 2.0),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.cardTitle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              title,
              style: AppTypography.cardTitle.copyWith(
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          const SizedBox(height: AppSpacing.xs + 2.0),
          Text(
            body,
            style: AppTypography.bodyMedium.copyWith(
              color: bodyColor,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

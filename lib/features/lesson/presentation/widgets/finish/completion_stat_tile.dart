import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Single white stat tile presenting a leading icon, bold value/status, and muted label.
///
/// Follows AGENTS.md §3 & §4: under 80 lines, build under 40 lines.
class CompletionStatTile extends StatelessWidget {
  const CompletionStatTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.label,
    required this.semanticLabel,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String label;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final labelColor = isDark ? AppColors.darkTextMuted : const Color(0xFF524F6B);

    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2.0,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: border, width: 1.0),
          boxShadow: isDark ? null : AppSpacing.cardShadow,
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(icon, color: iconColor, size: 26.0),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.cardTitle.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16.0,
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1.0),
                  Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

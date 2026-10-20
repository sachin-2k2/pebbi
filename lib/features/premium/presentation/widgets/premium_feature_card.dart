import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Single white value-proposition card displaying an emoji, bold title, and caption.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// flexible sizing without fixed height, WCAG AA compliant contrast (> 4.5:1).
class PremiumFeatureCard extends StatelessWidget {
  const PremiumFeatureCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.caption,
  });

  final String emoji;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final captionColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Semantics(
      label: AppStrings.featureCardSemantics(title, caption),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + 2.0,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          boxShadow: isDark ? null : AppSpacing.cardShadow,
          border: isDark
              ? Border.all(color: AppColors.darkBorder, width: 1.0)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24.0, height: 1.0),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: Text(
                caption,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 12.0,
                  height: 1.35,
                  color: captionColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

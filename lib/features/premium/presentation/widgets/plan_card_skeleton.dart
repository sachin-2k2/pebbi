import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Loading skeleton placeholder for the subscription plan card.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// displays exclusively for the plan card while the benefits grid renders immediately.
class PlanCardSkeleton extends StatelessWidget {
  const PlanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final blockColor = isDark ? AppColors.darkBorder : AppColors.disabled;

    return Semantics(
      label: 'Loading subscription options',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          boxShadow: isDark ? null : AppSpacing.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _skeletonBox(width: 130.0, height: 22.0, color: blockColor),
            const SizedBox(height: AppSpacing.md),
            _skeletonBox(width: 100.0, height: 36.0, color: blockColor),
            const SizedBox(height: AppSpacing.sm),
            _skeletonBox(width: 220.0, height: 16.0, color: blockColor),
            const SizedBox(height: AppSpacing.lg),
            _skeletonBox(width: 180.0, height: 14.0, color: blockColor),
            const SizedBox(height: AppSpacing.sm),
            _skeletonBox(width: 210.0, height: 14.0, color: blockColor),
            const SizedBox(height: AppSpacing.sm),
            _skeletonBox(width: 160.0, height: 14.0, color: blockColor),
            const SizedBox(height: AppSpacing.xl),
            _skeletonBox(
              width: double.infinity,
              height: AppSpacing.buttonHeightMd,
              borderRadius: AppSpacing.radiusButton,
              color: blockColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonBox({
    required double width,
    required double height,
    required Color color,
    double borderRadius = AppSpacing.radiusSm,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

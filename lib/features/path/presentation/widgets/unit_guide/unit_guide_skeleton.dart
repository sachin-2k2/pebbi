import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Loading skeleton view displayed while unit guidebook data resolves.
///
/// Follows AGENTS.md §3: under 100 lines, build under 50 lines.
class UnitGuideSkeleton extends StatelessWidget {
  const UnitGuideSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final baseColor = palette.surfaceVariant.withValues(alpha: 0.6);

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildShimmerBlock(width: 200.0, height: 26.0, color: baseColor),
        const SizedBox(height: AppSpacing.xs),
        _buildShimmerBlock(width: 140.0, height: 16.0, color: baseColor),
        const SizedBox(height: AppSpacing.lg),
        _buildShimmerBlock(
          width: double.infinity,
          height: 52.0,
          color: baseColor,
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildShimmerBlock(width: 100.0, height: 16.0, color: baseColor),
        const SizedBox(height: AppSpacing.md),
        for (int i = 0; i < 4; i++) ...[
          _buildShimmerBlock(
            width: double.infinity,
            height: 60.0,
            color: baseColor,
            radius: AppSpacing.radiusIconTile,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  Widget _buildShimmerBlock({
    required double width,
    required double height,
    required Color color,
    double radius = AppSpacing.radiusSm,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

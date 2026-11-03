import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Card displaying personalized praise feedback from the debrief endpoint.
class DebriefPraiseCard extends StatelessWidget {
  const DebriefPraiseCard({super.key, required this.praise});

  final String praise;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.tintLavender,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: palette.brand.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: palette.brand, size: 20.0),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              praise,
              style: AppTypography.bodyMedium.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

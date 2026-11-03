import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Card displaying key vocabulary recap tags from the debrief endpoint.
class DebriefVocabCard extends StatelessWidget {
  const DebriefVocabCard({super.key, required this.vocabulary});

  final List<String> vocabulary;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: palette.outline),
        boxShadow: palette.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bookmark_outline_rounded, size: 18.0, color: palette.brand),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'VOCABULARY USED',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: palette.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: vocabulary.map((word) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: palette.tintLavender,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(color: palette.brand.withValues(alpha: 0.15)),
                ),
                child: Text(
                  word,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: palette.brandText,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

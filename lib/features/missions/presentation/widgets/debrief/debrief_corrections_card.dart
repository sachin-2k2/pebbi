import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/debrief_ref.dart';

/// Card showing actionable grammar & phrasing tips from the debrief endpoint.
class DebriefCorrectionsCard extends StatelessWidget {
  const DebriefCorrectionsCard({super.key, required this.corrections});

  final List<DebriefCorrection> corrections;

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
              Icon(Icons.lightbulb_outline_rounded, size: 18.0, color: palette.warningText),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'BETTER PHRASING',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: palette.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...corrections.map((c) => _CorrectionTile(correction: c)),
        ],
      ),
    );
  }
}

class _CorrectionTile extends StatelessWidget {
  const _CorrectionTile({required this.correction});

  final DebriefCorrection correction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.close_rounded, size: 14.0, color: palette.errorText),
              const SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  correction.userSaid,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: palette.textMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, size: 14.0, color: palette.mint),
              const SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  correction.betterWay,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.mint,
                  ),
                ),
              ),
            ],
          ),
          if (correction.explanation.isNotEmpty) ...[
            const SizedBox(height: 4.0),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Text(
                correction.explanation,
                style: AppTypography.caption.copyWith(color: palette.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

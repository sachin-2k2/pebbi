import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Card summarizing the goals completed in the mission session.
///
/// Follows AGENTS.md §3 (< 100 lines, build < 50 lines).
class DebriefGoalsCard extends StatelessWidget {
  const DebriefGoalsCard({
    super.key,
    required this.goalTexts,
    required this.missionId,
  });

  final List<String> goalTexts;
  final String missionId;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final items = goalTexts.isNotEmpty
        ? goalTexts
        : const ['Order a drink', 'Ask the price', 'Pay and say thank you'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: palette.outline, width: 1.0),
        boxShadow: palette.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'GOALS ACHIEVED',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: palette.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                missionId,
                style: AppTypography.caption.copyWith(
                  color: palette.textMuted,
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final goal in items) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: palette.mint,
                    size: 20.0,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      goal,
                      style: AppTypography.bodyMedium.copyWith(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}


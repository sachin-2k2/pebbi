import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/quest_item.dart';

/// Single quest row with emoji, title, target count, and thin progress bar.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.1.
class QuestRow extends StatelessWidget {
  const QuestRow({super.key, required this.quest});

  final QuestItem quest;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final countColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final trackColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.tintLavender.withValues(alpha: 0.8);
    final barFillColor = quest.progressRatio > 0.0
        ? AppColors.accentMint
        : AppColors.brandPurple;

    return Semantics(
      label: AppStrings.rewardsQuestSemantics(
        quest.label,
        quest.current,
        quest.target,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quest.emoji, style: const TextStyle(fontSize: 18.0)),
            const SizedBox(width: AppSpacing.sm + 4.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          quest.label,
                          style: AppTypography.cardTitle.copyWith(
                            color: labelColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${quest.current}/${quest.target}',
                        style: AppTypography.caption.copyWith(
                          color: countColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    child: LinearProgressIndicator(
                      value: quest.progressRatio,
                      minHeight: 6.0,
                      backgroundColor: trackColor,
                      valueColor: AlwaysStoppedAnimation<Color>(barFillColor),
                    ),
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

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/quest_item.dart';
import 'quest_row.dart';
import 'quests_chest_note.dart';

/// Card container displaying active quests, progress counts, and chest footnote.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.1.
class QuestsCard extends StatelessWidget {
  const QuestsCard({
    super.key,
    required this.quests,
    required this.completedCount,
    this.chestMessage,
  });

  final List<QuestItem> quests;
  final int completedCount;
  final String? chestMessage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final countColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border, width: 1.0),
        boxShadow: isDark ? null : AppSpacing.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 18.0)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppStrings.rewardsQuestsTitle,
                  style: AppTypography.cardTitle.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Text(
                AppStrings.rewardsQuestsDone(completedCount, quests.length),
                style: AppTypography.caption.copyWith(
                  color: countColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final quest in quests) QuestRow(quest: quest),
          const SizedBox(height: AppSpacing.sm + 2.0),
          QuestsChestNote(message: chestMessage),
        ],
      ),
    );
  }
}

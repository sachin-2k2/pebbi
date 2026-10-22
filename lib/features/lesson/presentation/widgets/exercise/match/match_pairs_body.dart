import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';
import '../../../../domain/exercise.dart';
import 'match_column.dart';
import 'match_progress_text.dart';

/// Body widget presenting the 2-column "Match the pairs" exercise (Item 8).
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 50 lines,
/// columns remain side-by-side even at 200% text scale.
class MatchPairsBody extends StatelessWidget {
  const MatchPairsBody({
    super.key,
    required this.exercise,
    required this.selectedTargetId,
    required this.selectedMeaningId,
    required this.matchedPairIds,
    required this.isWrongPairShake,
    required this.onSelectTarget,
    required this.onSelectMeaning,
  });

  final MatchPairsExercise exercise;
  final String? selectedTargetId;
  final String? selectedMeaningId;
  final Set<String> matchedPairIds;
  final bool isWrongPairShake;
  final ValueChanged<String> onSelectTarget;
  final ValueChanged<String> onSelectMeaning;

  @override
  Widget build(BuildContext context) {
    final targetItems = exercise.pairs.map((p) {
      return MatchColumnItem(
        id: p.id,
        text: p.targetText,
        isSelected: selectedTargetId == p.id,
        isMatched: matchedPairIds.contains(p.id),
        isShaking: isWrongPairShake && selectedTargetId == p.id,
      );
    }).toList();

    final meaningMap = {for (final p in exercise.pairs) p.id: p};
    final meaningItems = exercise.displayMeaningIds.map((id) {
      final pair = meaningMap[id]!;
      return MatchColumnItem(
        id: pair.id,
        text: pair.meaningText,
        isSelected: selectedMeaningId == pair.id,
        isMatched: matchedPairIds.contains(pair.id),
        isShaking: isWrongPairShake && selectedMeaningId == pair.id,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MatchProgressText(
            matchedCount: matchedPairIds.length,
            totalPairs: exercise.pairs.length,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MatchColumn(
                  items: targetItems,
                  onCardTap: onSelectTarget,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: MatchColumn(
                  items: meaningItems,
                  onCardTap: onSelectMeaning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '✨ ${AppStrings.matchPairsNote}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

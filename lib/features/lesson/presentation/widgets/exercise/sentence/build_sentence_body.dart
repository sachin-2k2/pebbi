import 'package:flutter/material.dart';
import '../../../../../../core/design_system/tip_pill.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../l10n/app_strings.dart';
import '../../../../domain/exercise.dart';
import '../../../../domain/word_tile_item.dart';
import 'answer_area.dart';
import 'prompt_bubble.dart';
import 'word_bank.dart';

/// Middle body layout for the "Build the sentence" exercise.
///
/// Follows AGENTS.md §3: under 100 lines, build under 50 lines.
/// Left-aligned content: Prompt bubble, answer area, word bank, and tip pill.
class BuildSentenceBody extends StatelessWidget {
  const BuildSentenceBody({
    super.key,
    required this.exercise,
    required this.placedTileIds,
    required this.onPlaceTile,
    required this.onRemoveTile,
    this.isLocked = false,
  });

  final BuildSentenceExercise exercise;
  final List<String> placedTileIds;
  final void Function(String tileId) onPlaceTile;
  final void Function(String tileId) onRemoveTile;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final tileMap = {for (final tile in exercise.tiles) tile.id: tile};
    final placedTiles = placedTileIds
        .map((id) => tileMap[id])
        .whereType<WordTileItem>()
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          PromptBubble(promptText: exercise.prompt),
          const SizedBox(height: AppSpacing.lg),
          AnswerArea(
            placedTiles: placedTiles,
            onTileTap: onRemoveTile,
            isLocked: isLocked,
          ),
          const SizedBox(height: AppSpacing.lg),
          WordBank(
            allTiles: exercise.tiles,
            placedTileIds: placedTileIds,
            onTileTap: onPlaceTile,
            isLocked: isLocked,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Center(child: TipPill(message: AppStrings.tilesFlyUpTip)),
        ],
      ),
    );
  }
}

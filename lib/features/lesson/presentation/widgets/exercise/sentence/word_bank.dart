import 'package:flutter/material.dart';
import '../../../../../../l10n/app_strings.dart';
import '../../../../domain/word_tile_item.dart';
import 'word_tile.dart';

/// Word bank displaying candidate word tiles in their source positions.
///
/// Follows AGENTS.md §3: under 100 lines, build under 50 lines.
/// Preserves ghost slot placeholders when tiles are placed to prevent UI reflow.
class WordBank extends StatelessWidget {
  const WordBank({
    super.key,
    required this.allTiles,
    required this.placedTileIds,
    required this.onTileTap,
    this.isLocked = false,
  });

  final List<WordTileItem> allTiles;
  final List<String> placedTileIds;
  final void Function(String tileId) onTileTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: [for (final tile in allTiles) _buildTile(tile)],
    );
  }

  Widget _buildTile(WordTileItem tile) {
    final isPlaced = placedTileIds.contains(tile.id);

    if (isPlaced) {
      return WordTile(
        key: ValueKey('bank_placeholder_${tile.id}'),
        tile: tile,
        visualState: WordTileVisualState.placeholderSlot,
      );
    }

    return WordTile(
      key: ValueKey('bank_active_${tile.id}'),
      tile: tile,
      visualState: isLocked
          ? WordTileVisualState.locked
          : WordTileVisualState.inBank,
      semanticsLabel: AppStrings.tileInBankSemantics(tile.text),
      onTap: () => onTileTap(tile.id),
    );
  }
}

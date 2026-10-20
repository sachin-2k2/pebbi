import 'word_tile_item.dart';

/// Pure Dart entity representing the state of word tile arrangement in a sentence.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
/// Tiles are compared by [id] to safely support sentences with repeated words.
class SentenceArrangement {
  const SentenceArrangement({
    required this.allTiles,
    this.placedTileIds = const [],
  });

  /// All available tiles in their original bank order.
  final List<WordTileItem> allTiles;

  /// IDs of tiles currently placed in the answer area, in tap order.
  final List<String> placedTileIds;

  /// Whether a tile with [tileId] is currently placed in the answer area.
  bool isPlaced(String tileId) => placedTileIds.contains(tileId);

  /// The list of placed [WordTileItem] in order of their placement.
  List<WordTileItem> get placedTiles {
    final tileMap = {for (final tile in allTiles) tile.id: tile};
    return placedTileIds
        .map((id) => tileMap[id])
        .whereType<WordTileItem>()
        .toList();
  }

  /// The concatenated text of the placed tiles separated by spaces.
  String get assembledSentence =>
      placedTiles.map((tile) => tile.text).join(' ');

  /// Places a tile by ID into the answer area if not already placed.
  SentenceArrangement place(String tileId) {
    if (isPlaced(tileId)) return this;
    final exists = allTiles.any((t) => t.id == tileId);
    if (!exists) return this;
    return SentenceArrangement(
      allTiles: allTiles,
      placedTileIds: [...placedTileIds, tileId],
    );
  }

  /// Removes a placed tile by ID, returning it to its slot in the word bank.
  SentenceArrangement remove(String tileId) {
    if (!isPlaced(tileId)) return this;
    return SentenceArrangement(
      allTiles: allTiles,
      placedTileIds: placedTileIds.where((id) => id != tileId).toList(),
    );
  }

  /// Clears all placed tiles.
  SentenceArrangement reset() =>
      SentenceArrangement(allTiles: allTiles, placedTileIds: const []);
}

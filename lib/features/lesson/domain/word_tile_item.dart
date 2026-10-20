/// Represents an individual draggable/tappable word tile in a sentence building exercise.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
/// Tiles are compared by [id], not [text], to safely support duplicate words.
class WordTileItem {
  const WordTileItem({required this.id, required this.text});

  /// Unique identifier of the tile (e.g. 'q7_tile_ida').
  final String id;

  /// Display text of the tile (e.g. 'Ida').
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordTileItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WordTileItem($id, "$text")';
}

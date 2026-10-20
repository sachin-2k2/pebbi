/// Pure Dart domain model representing a selectable onboarding starter sticker option.
///
/// Follows AGENTS.md §2.2: Zero Flutter imports so it can be unit tested in any Dart environment.
class StickerOption {
  const StickerOption({
    required this.id,
    required this.emoji,
    required this.title,
  });

  /// Stable unique identifier matching prototype store: 'wave', 'sparkle', 'wellsaid'.
  final String id;

  /// Graphical emoji character for display.
  final String emoji;

  /// Human-readable title: 'First hello', 'Little spark', 'Well said'.
  final String title;

  static const List<StickerOption> options = [
    StickerOption(id: 'wave', emoji: '👋', title: 'First hello'),
    StickerOption(id: 'sparkle', emoji: '✨', title: 'Little spark'),
    StickerOption(id: 'wellsaid', emoji: '👍', title: 'Well said'),
  ];

  static StickerOption? findById(String? id) {
    if (id == null) return null;
    for (final opt in options) {
      if (opt.id == id) return opt;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StickerOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          emoji == other.emoji &&
          title == other.title;

  @override
  int get hashCode => Object.hash(id, emoji, title);
}

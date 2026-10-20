/// Domain model representing a mission category filter.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class MissionCategory {
  const MissionCategory({
    required this.id,
    required this.title,
    this.emoji = '',
  });

  /// Distinct category identifier (e.g. 'all', 'everyday', 'travel').
  final String id;

  /// Display title (e.g. 'All', 'Everyday', 'Travel').
  final String title;

  /// Optional display emoji.
  final String emoji;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissionCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          emoji == other.emoji;

  @override
  int get hashCode => Object.hash(id, title, emoji);
}

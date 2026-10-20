/// Pure domain model representing a learning track.
///
/// Follows AGENTS.md §2.2: Pure Dart model with zero Flutter imports.
class Track {
  const Track({
    required this.id,
    required this.title,
    required this.emoji,
    this.hasContent = true,
  });

  final String id;
  final String title;
  final String emoji;
  final bool hasContent;
}

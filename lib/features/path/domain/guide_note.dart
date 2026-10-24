/// Display-only grammar or culture note within a unit guidebook.
///
/// Follows AGENTS.md §2 (pure domain rules, zero Flutter imports).
class GuideNote {
  const GuideNote({
    required this.id,
    this.emoji,
    required this.title,
    required this.body,
    required this.tag,
    this.isRtl = false,
  });

  final String id;
  final String? emoji;
  final String title;
  final String body;

  /// Semantic tag identifier (e.g. 'grammar', 'culture', or custom tag).
  final String tag;

  final bool isRtl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuideNote &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          emoji == other.emoji &&
          title == other.title &&
          body == other.body &&
          tag == other.tag &&
          isRtl == other.isRtl;

  @override
  int get hashCode =>
      id.hashCode ^
      emoji.hashCode ^
      title.hashCode ^
      body.hashCode ^
      tag.hashCode ^
      isRtl.hashCode;
}

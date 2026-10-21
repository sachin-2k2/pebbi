/// Lightweight summary of a grammar and culture note for display in the Library list.
///
/// Follows AGENTS.md §2 (pure domain rules, zero Flutter imports).
class GrammarNoteSummary {
  const GrammarNoteSummary({
    required this.id,
    required this.emoji,
    required this.title,
    required this.excerpt,
    required this.languageCode,
    required this.levelId,
    this.isRead = false,
    this.isCached = false,
    this.dots,
  });

  final String id;
  final String emoji;
  final String title;
  final String excerpt;
  final String languageCode;
  final String levelId;
  final bool isRead;
  final bool isCached;

  /// Optional trailing dots indicator (0 to 3) from the prototype design.
  /// Hidden from screen readers. Marked TODO(question).
  final int? dots;

  GrammarNoteSummary copyWith({
    String? id,
    String? emoji,
    String? title,
    String? excerpt,
    String? languageCode,
    String? levelId,
    bool? isRead,
    bool? isCached,
    int? dots,
  }) {
    return GrammarNoteSummary(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      title: title ?? this.title,
      excerpt: excerpt ?? this.excerpt,
      languageCode: languageCode ?? this.languageCode,
      levelId: levelId ?? this.levelId,
      isRead: isRead ?? this.isRead,
      isCached: isCached ?? this.isCached,
      dots: dots ?? this.dots,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrammarNoteSummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          emoji == other.emoji &&
          title == other.title &&
          excerpt == other.excerpt &&
          languageCode == other.languageCode &&
          levelId == other.levelId &&
          isRead == other.isRead &&
          isCached == other.isCached &&
          dots == other.dots;

  @override
  int get hashCode =>
      id.hashCode ^
      emoji.hashCode ^
      title.hashCode ^
      excerpt.hashCode ^
      languageCode.hashCode ^
      levelId.hashCode ^
      isRead.hashCode ^
      isCached.hashCode ^
      dots.hashCode;
}

/// Summary of counts and readiness for practice rooms.
///
/// Follows AGENTS.md §2 (pure domain rules, no Flutter imports).
class PracticeSummary {
  const PracticeSummary({
    this.reviewedPhraseCount = 0,
    this.flashcardCount = 0,
    this.trickyCount = 0,
    this.mixMinutes = 2,
    this.isMixAvailable = false,
  });

  final int reviewedPhraseCount;
  final int flashcardCount;
  final int trickyCount;
  final int mixMinutes;
  final bool isMixAvailable;

  PracticeSummary copyWith({
    int? reviewedPhraseCount,
    int? flashcardCount,
    int? trickyCount,
    int? mixMinutes,
    bool? isMixAvailable,
  }) {
    return PracticeSummary(
      reviewedPhraseCount: reviewedPhraseCount ?? this.reviewedPhraseCount,
      flashcardCount: flashcardCount ?? this.flashcardCount,
      trickyCount: trickyCount ?? this.trickyCount,
      mixMinutes: mixMinutes ?? this.mixMinutes,
      isMixAvailable: isMixAvailable ?? this.isMixAvailable,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PracticeSummary &&
          runtimeType == other.runtimeType &&
          reviewedPhraseCount == other.reviewedPhraseCount &&
          flashcardCount == other.flashcardCount &&
          trickyCount == other.trickyCount &&
          mixMinutes == other.mixMinutes &&
          isMixAvailable == other.isMixAvailable;

  @override
  int get hashCode =>
      reviewedPhraseCount.hashCode ^
      flashcardCount.hashCode ^
      trickyCount.hashCode ^
      mixMinutes.hashCode ^
      isMixAvailable.hashCode;
}

import 'self_check_reason.dart';

/// Detailed record of performance on a single item in a lesson.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class ItemRecord {
  const ItemRecord({
    required this.itemId,
    this.seen = true,
    this.firstTryCorrect,
    this.hintsUsed = 0,
    this.attempts = 1,
    this.skipped = false,
    this.credit = 1.0,
    this.selfCheckReason,
  });

  final String itemId;
  final bool seen;

  /// Null for teach/unscored cards; true/false for scored exercises.
  final bool? firstTryCorrect;
  final int hintsUsed;
  final int attempts;
  final bool skipped;

  /// Earned credit for this item: 1.0 full, 0.5 half (self-check), 0.0 skipped.
  final double credit;

  /// If this item fell back to self-check, the reason why.
  final SelfCheckReason? selfCheckReason;

  ItemRecord copyWith({
    String? itemId,
    bool? seen,
    bool? firstTryCorrect,
    int? hintsUsed,
    int? attempts,
    bool? skipped,
    double? credit,
    SelfCheckReason? selfCheckReason,
  }) {
    return ItemRecord(
      itemId: itemId ?? this.itemId,
      seen: seen ?? this.seen,
      firstTryCorrect: firstTryCorrect ?? this.firstTryCorrect,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      attempts: attempts ?? this.attempts,
      skipped: skipped ?? this.skipped,
      credit: credit ?? this.credit,
      selfCheckReason: selfCheckReason ?? this.selfCheckReason,
    );
  }
}

/// Aggregated result of a completed lesson session.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class LessonResult {
  const LessonResult({
    required this.stopId,
    required this.userId,
    required this.totalItems,
    required this.itemRecords,
    required this.completedAt,
  });

  final String stopId;
  final String userId;
  final int totalItems;
  final Map<String, ItemRecord> itemRecords;
  final DateTime completedAt;

  /// Total scored items in the lesson.
  int get scoredItemCount =>
      itemRecords.values.where((r) => r.firstTryCorrect != null).length;

  /// Count of scored items answered correctly on the first try.
  int get firstTryCorrectCount =>
      itemRecords.values.where((r) => r.firstTryCorrect == true).length;

  /// Overall first-try accuracy score percentage (0-100%).
  int get firstTryPercentage {
    if (scoredItemCount == 0) return 100;
    return ((firstTryCorrectCount / scoredItemCount) * 100).round();
  }

  /// Total mistakes made across all scored items.
  int get totalMistakes =>
      itemRecords.values.where((r) => r.firstTryCorrect == false).length;
}

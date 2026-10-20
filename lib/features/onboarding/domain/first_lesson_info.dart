/// Pure Dart domain model representing information about the learner's first path stop.
///
/// Follows AGENTS.md §2.2: Pure Dart with zero Flutter imports.
class FirstLessonInfo {
  const FirstLessonInfo({
    this.lessonNumber = 1,
    this.estimatedMinutes = 3,
    this.unitNumber = 1,
    this.title = 'Hello & First Words',
  });

  /// Sequential lesson number on the learner's path (default: 1).
  final int lessonNumber;

  /// Estimated completion duration in minutes (default: 3).
  final int estimatedMinutes;

  /// Parent unit number (default: 1).
  final int unitNumber;

  /// Descriptive lesson title.
  final String title;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirstLessonInfo &&
          runtimeType == other.runtimeType &&
          lessonNumber == other.lessonNumber &&
          estimatedMinutes == other.estimatedMinutes &&
          unitNumber == other.unitNumber &&
          title == other.title;

  @override
  int get hashCode =>
      Object.hash(lessonNumber, estimatedMinutes, unitNumber, title);
}

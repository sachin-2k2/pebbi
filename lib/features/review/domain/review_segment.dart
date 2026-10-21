/// Primary segments of the Review tab.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
enum ReviewSegment {
  phrases('phrases'),
  practice('practice'),
  library('library');

  const ReviewSegment(this.id);
  final String id;
}

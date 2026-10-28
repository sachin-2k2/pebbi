import 'language_level.dart';

/// Placement quiz evaluation result returned by the backend.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class PlacementSubmissionResult {
  const PlacementSubmissionResult({
    required this.score,
    required this.total,
    required this.scorePct,
    required this.level,
    this.estimatedNote,
    this.identity,
    this.emoji,
    this.message,
  });

  final int score;
  final int total;
  final int scorePct;
  final LanguageLevel level;
  final String? estimatedNote;
  final String? identity;
  final String? emoji;
  final String? message;
}

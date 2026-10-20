import 'learning_reason.dart';

/// Repository interface for retrieving learning reason options.
///
/// Follows AGENTS.md §1 & §2: Pure Dart interface, hides data source.
abstract interface class LearningReasonRepository {
  /// Returns the catalog of learning reasons.
  List<LearningReason> getReasons();
}

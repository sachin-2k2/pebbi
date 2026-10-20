import 'home_summary.dart';

/// Repository interface managing the display counters and active session summary.
///
/// Follows AGENTS.md §2.2: Pure Dart interface with zero Flutter imports.
abstract interface class HomeSummaryRepository {
  /// Fetches the display summary for the active [userId].
  Future<HomeSummary> getHomeSummary({required String userId});
}

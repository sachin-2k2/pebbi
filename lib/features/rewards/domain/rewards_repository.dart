import 'rewards_summary.dart';

/// Abstract repository interface for Rewards data.
///
/// Follows AGENTS.md §2.2: Pure Dart domain interface with zero Flutter imports.
abstract class RewardsRepository {
  /// Fetches the aggregated rewards summary for the given [userId].
  Future<RewardsSummary> getSummary({required String userId});

  /// Watches real-time updates to the rewards summary for [userId].
  Stream<RewardsSummary> watchSummary({required String userId});
}

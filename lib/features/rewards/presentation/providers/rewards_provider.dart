import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/mock_rewards_repository.dart';
import '../../domain/rewards_repository.dart';
import '../../domain/rewards_summary.dart';

/// Provider for the Rewards repository instance.
final rewardsRepositoryProvider = Provider<RewardsRepository>((ref) {
  return MockRewardsRepository();
});

/// Global key used by the calendar quick action pill to scroll to the calendar card.
final calendarScrollKeyProvider = Provider<GlobalKey>((ref) {
  return GlobalKey();
});

/// Aggregated user rewards summary.
///
/// Follows AGENTS.md §6: Strictly watches [currentUserProvider] to isolate data across users.
final rewardsSummaryProvider = FutureProvider.autoDispose<RewardsSummary>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  final userId = user?.userId ?? 'guest_default';
  final repository = ref.watch(rewardsRepositoryProvider);
  return repository.getSummary(userId: userId);
});

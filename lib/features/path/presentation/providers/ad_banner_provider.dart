import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/domain/age_band.dart';
import '../../data/mock_ad_repository.dart';
import '../../domain/ad_repository.dart';
import '../../domain/ad_rules.dart';

/// Provider for [AdRepository].
final adRepositoryProvider = Provider<AdRepository>((ref) {
  return const MockAdRepository();
});

/// Connectivity state provider for ad banner eligibility.
final isOnlineProvider = StateProvider<bool>((ref) => true);

/// Determines whether the ad banner should be rendered on the Path screen.
final shouldShowAdBannerProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  final isOnline = ref.watch(isOnlineProvider);

  return AdRules.shouldShowAds(
    ageBand: user?.ageBand ?? AgeBand.adult,
    isPremium: user?.isPremium ?? false,
    isOnline: isOnline,
  );
});

/// Provider loading the active house ad.
final activeAdBannerProvider = FutureProvider<HouseAd?>((ref) async {
  final shouldShow = ref.watch(shouldShowAdBannerProvider);
  if (!shouldShow) return null;

  final repository = ref.watch(adRepositoryProvider);
  return repository.getActiveAd();
});

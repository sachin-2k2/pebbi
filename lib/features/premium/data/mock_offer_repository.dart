import '../domain/offer_repository.dart';
import '../domain/subscription_offer.dart';

/// Mock implementation of [OfferRepository] returning realistic store data.
///
/// Follows AGENTS.md §1 & §2: Placeholder repository until store APIs
/// (In-App Purchases / StoreKit / Google Play Billing) are integrated.
class MockOfferRepository implements OfferRepository {
  const MockOfferRepository({
    this.delay = Duration.zero,
    this.shouldFail = false,
    this.offer = const SubscriptionOffer(
      trialDays: 7,
      formattedPrice: r'$3.99',
      period: 'month',
      canWatchAdForFreeDay: true,
    ),
  });

  final Duration delay;
  final bool shouldFail;
  final SubscriptionOffer offer;

  @override
  Future<SubscriptionOffer> getIntroductoryOffer() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (shouldFail) {
      throw StateError('Store unavailable: unable to load subscription offer.');
    }
    return offer;
  }
}

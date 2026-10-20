import 'subscription_offer.dart';

/// Repository interface for retrieving store subscription offers.
///
/// Follows AGENTS.md §2.2: Pure Dart interface with zero Flutter imports.
abstract interface class OfferRepository {
  /// Fetches the introductory subscription offer with trial and localized pricing.
  Future<SubscriptionOffer> getIntroductoryOffer();
}

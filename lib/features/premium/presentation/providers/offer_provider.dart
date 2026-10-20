import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_offer_repository.dart';
import '../../domain/offer_repository.dart';
import '../../domain/subscription_offer.dart';

/// Provider for the [OfferRepository].
final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  return const MockOfferRepository();
});

/// Asynchronous provider fetching the introductory subscription offer.
final introductoryOfferProvider = FutureProvider<SubscriptionOffer>((
  ref,
) async {
  final repository = ref.watch(offerRepositoryProvider);
  return repository.getIntroductoryOffer();
});

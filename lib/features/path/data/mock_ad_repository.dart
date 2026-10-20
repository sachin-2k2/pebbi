import '../domain/ad_repository.dart';

/// Mock implementation of [AdRepository] providing a house advertisement banner.
///
/// Follows AGENTS.md §1 & §4: Ad prices are dynamic (never hardcoded in widgets).
class MockAdRepository implements AdRepository {
  const MockAdRepository({this.priceString = r'$3.99/month'});

  final String priceString;

  @override
  Future<HouseAd?> getActiveAd() async {
    return HouseAd(
      id: 'wordsnap_ad_1',
      title: 'WordSnap · ten words a day',
      caption: 'Sponsored. Free learners see one small ad like this.',
      priceString: priceString,
      ctaLabel: 'Remove ads · Premium $priceString',
    );
  }
}

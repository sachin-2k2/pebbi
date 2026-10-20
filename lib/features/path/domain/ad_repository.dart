/// Pure domain model for house advertisement banner.
///
/// Follows AGENTS.md §2.2: Pure Dart model with zero Flutter imports.
class HouseAd {
  const HouseAd({
    required this.id,
    required this.title,
    required this.caption,
    required this.priceString,
    this.ctaLabel = 'Remove ads · Premium',
  });

  final String id;
  final String title;
  final String caption;
  final String priceString;
  final String ctaLabel;
}

/// Repository interface managing house advertisement data.
abstract interface class AdRepository {
  /// Fetches the currently active house ad with dynamic offer pricing.
  Future<HouseAd?> getActiveAd();
}

/// Domain model representing a purchasable subscription tier.
///
/// Follows AGENTS.md §2.2: Pure Dart domain model with zero Flutter imports.
/// Prices, periods, and trial days come from platform store data, never hardcoded in UI.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.formattedPrice,
    required this.billingPeriod,
    required this.trialDays,
    this.isMostPopular = false,
    this.trialEligible = true,
    required this.benefits,
  });

  /// Unique product identifier (e.g. `pebbi_monthly`).
  final String id;

  /// Localized plan title (e.g. `Pebbi Monthly`).
  final String title;

  /// Store-formatted price with localized currency symbol (e.g. `$3.99`, `£3.49`).
  final String formattedPrice;

  /// Recurring billing period name (e.g. `month`, `year`).
  final String billingPeriod;

  /// Length of introductory free trial in days (e.g. 7).
  final int trialDays;

  /// Whether to display the "Most popular" badge pill.
  final bool isMostPopular;

  /// Whether the user is eligible for an introductory free trial.
  final bool trialEligible;

  /// List of localized benefit descriptions included in this tier.
  final List<String> benefits;

  SubscriptionPlan copyWith({
    String? id,
    String? title,
    String? formattedPrice,
    String? billingPeriod,
    int? trialDays,
    bool? isMostPopular,
    bool? trialEligible,
    List<String>? benefits,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      formattedPrice: formattedPrice ?? this.formattedPrice,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      trialDays: trialDays ?? this.trialDays,
      isMostPopular: isMostPopular ?? this.isMostPopular,
      trialEligible: trialEligible ?? this.trialEligible,
      benefits: benefits ?? this.benefits,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionPlan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          formattedPrice == other.formattedPrice &&
          billingPeriod == other.billingPeriod &&
          trialDays == other.trialDays &&
          isMostPopular == other.isMostPopular &&
          trialEligible == other.trialEligible &&
          _listEquals(benefits, other.benefits);

  @override
  int get hashCode => Object.hash(
    id,
    title,
    formattedPrice,
    billingPeriod,
    trialDays,
    isMostPopular,
    trialEligible,
    Object.hashAll(benefits),
  );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

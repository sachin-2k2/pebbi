/// Domain model representing a subscription introductory offer.
///
/// Follows AGENTS.md §2.2: Pure Dart model with zero Flutter imports.
/// Price formatting and trial lengths come from store data, never hardcoded.
class SubscriptionOffer {
  const SubscriptionOffer({
    required this.trialDays,
    required this.formattedPrice,
    required this.period,
    this.canWatchAdForFreeDay = true,
  });

  /// Duration of the introductory free trial in days (e.g. 7).
  final int trialDays;

  /// Localized price string formatted by the platform store (e.g. "$3.99", "£3.49").
  final String formattedPrice;

  /// Recurring billing period name (e.g. "month", "year").
  final String period;

  /// Whether the user is eligible to unlock a 24-hour pass by watching a rewarded ad.
  final bool canWatchAdForFreeDay;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionOffer &&
          runtimeType == other.runtimeType &&
          trialDays == other.trialDays &&
          formattedPrice == other.formattedPrice &&
          period == other.period &&
          canWatchAdForFreeDay == other.canWatchAdForFreeDay;

  @override
  int get hashCode =>
      Object.hash(trialDays, formattedPrice, period, canWatchAdForFreeDay);
}

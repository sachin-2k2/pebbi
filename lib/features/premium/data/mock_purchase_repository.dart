import '../../../l10n/app_strings.dart';
import '../domain/purchase_repository.dart';
import '../domain/purchase_state.dart';
import '../domain/subscription_plan.dart';

/// In-memory mock implementation of [PurchaseRepository].
///
/// Follows AGENTS.md §1 & §2.2: Mock implementation with realistic sample data.
/// Prepares for future store-specific implementation (StoreKit / Play Billing)
/// without requiring changes to presentation layers.
class MockPurchaseRepository implements PurchaseRepository {
  MockPurchaseRepository({
    List<SubscriptionPlan>? initialPlans,
    this.shouldFailLoadPlans = false,
    this.purchaseResult = PurchaseStatus.success,
    this.restoreResult = PurchaseStatus.success,
    bool initialIsPremium = false,
    this.delay = Duration.zero,
  }) : _plans = initialPlans ?? defaultPlans,
       _isPremium = initialIsPremium;

  /// Default monthly subscription plan matching the design specification.
  static const List<SubscriptionPlan> defaultPlans = [
    SubscriptionPlan(
      id: 'pebbi_monthly',
      title: AppStrings.defaultPlanTitle,
      formattedPrice: r'$3.99',
      billingPeriod: 'month',
      trialDays: 7,
      isMostPopular: true,
      trialEligible: true,
      benefits: [
        AppStrings.planBenefitEveryUnit,
        AppStrings.planBenefitChestsBadges,
        AppStrings.planBenefitCancelAnyTime,
      ],
    ),
  ];

  final List<SubscriptionPlan> _plans;
  final bool shouldFailLoadPlans;
  final PurchaseStatus purchaseResult;
  final PurchaseStatus restoreResult;
  final Duration delay;

  bool _isPremium;
  int purchaseCallCount = 0;
  int restoreCallCount = 0;
  String? lastPurchasedPlanId;

  @override
  Future<List<SubscriptionPlan>> loadPlans() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (shouldFailLoadPlans) {
      throw Exception('Network error: failed to load subscription plans.');
    }
    return List.unmodifiable(_plans);
  }

  @override
  Future<PurchaseStatus> purchase(String planId) async {
    purchaseCallCount++;
    lastPurchasedPlanId = planId;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (purchaseResult == PurchaseStatus.success) {
      _isPremium = true;
    }
    return purchaseResult;
  }

  @override
  Future<PurchaseStatus> restore() async {
    restoreCallCount++;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (restoreResult == PurchaseStatus.success) {
      _isPremium = true;
    }
    return restoreResult;
  }

  @override
  Future<bool> status() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return _isPremium;
  }
}

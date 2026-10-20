import 'purchase_state.dart';
import 'subscription_plan.dart';

/// Contract for managing subscription plans and store transactions.
///
/// Follows AGENTS.md §2.2: Pure Dart interface with zero Flutter imports.
/// Decouples UI presentation from backend and platform store logic.
abstract interface class PurchaseRepository {
  /// Fetches available subscription plans formatted by the store for the user's region.
  Future<List<SubscriptionPlan>> loadPlans();

  /// Initiates a purchase for the specified [planId].
  Future<PurchaseStatus> purchase(String planId);

  /// Restores previous in-app purchases (mandated by Apple Store guidelines).
  Future<PurchaseStatus> restore();

  /// Checks the current active premium entitlement status.
  Future<bool> status();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/mock_purchase_repository.dart';
import '../../domain/purchase_repository.dart';
import '../../domain/purchase_state.dart';
import '../../domain/subscription_plan.dart';

/// Provider exposing the active [PurchaseRepository].
final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return MockPurchaseRepository();
});

/// Asynchronously fetches available subscription plans.
final subscriptionPlansProvider =
    FutureProvider.autoDispose<List<SubscriptionPlan>>((ref) async {
      final repository = ref.watch(purchaseRepositoryProvider);
      return repository.loadPlans();
    });

/// Asynchronously checks current premium status from the repository.
final isPremiumStatusProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repository = ref.watch(purchaseRepositoryProvider);
  return repository.status();
});

/// Manages active purchase transaction states with double-tap protection.
class PurchaseNotifier extends StateNotifier<PurchaseState> {
  PurchaseNotifier(this._repository, this._ref) : super(const PurchaseState());

  final PurchaseRepository _repository;
  final Ref _ref;

  /// Initiates a purchase for [planId], guarding against concurrent taps.
  Future<PurchaseStatus> purchase(String planId) async {
    if (state.isLoading) {
      return PurchaseStatus.loading;
    }

    state = PurchaseState(status: PurchaseStatus.loading, activePlanId: planId);

    try {
      final result = await _repository.purchase(planId);

      switch (result) {
        case PurchaseStatus.success:
          final currentUser = _ref.read(currentUserProvider);
          if (currentUser != null) {
            await _ref
                .read(currentUserProvider.notifier)
                .saveProfile(currentUser.copyWith(plan: 'premium'));
          }
          state = PurchaseState(
            status: PurchaseStatus.success,
            activePlanId: planId,
          );
          _ref.invalidate(isPremiumStatusProvider);
          return PurchaseStatus.success;

        case PurchaseStatus.cancelled:
          // User cancelled: silent return to idle per requirements
          state = const PurchaseState(status: PurchaseStatus.idle);
          return PurchaseStatus.cancelled;

        case PurchaseStatus.pending:
          state = PurchaseState(
            status: PurchaseStatus.pending,
            activePlanId: planId,
          );
          return PurchaseStatus.pending;

        case PurchaseStatus.error:
        case PurchaseStatus.idle:
        case PurchaseStatus.loading:
          state = PurchaseState(
            status: PurchaseStatus.error,
            activePlanId: planId,
            errorMessage: AppStrings.purchaseErrorBanner,
          );
          return PurchaseStatus.error;
      }
    } catch (_) {
      state = PurchaseState(
        status: PurchaseStatus.error,
        activePlanId: planId,
        errorMessage: AppStrings.purchaseErrorBanner,
      );
      return PurchaseStatus.error;
    }
  }

  /// Restores user purchases (required for iOS store compliance).
  Future<PurchaseStatus> restorePurchases() async {
    if (state.isLoading) return PurchaseStatus.loading;

    state = const PurchaseState(status: PurchaseStatus.loading);
    try {
      final result = await _repository.restore();
      if (result == PurchaseStatus.success) {
        final currentUser = _ref.read(currentUserProvider);
        if (currentUser != null) {
          await _ref
              .read(currentUserProvider.notifier)
              .saveProfile(currentUser.copyWith(plan: 'premium'));
        }
        state = const PurchaseState(status: PurchaseStatus.success);
        _ref.invalidate(isPremiumStatusProvider);
      } else {
        state = const PurchaseState(status: PurchaseStatus.idle);
      }
      return result;
    } catch (_) {
      state = const PurchaseState(
        status: PurchaseStatus.error,
        errorMessage: AppStrings.purchaseErrorBanner,
      );
      return PurchaseStatus.error;
    }
  }

  void clearError() {
    if (state.isError) {
      state = state.copyWith(status: PurchaseStatus.idle, clearError: true);
    }
  }

  void reset() {
    state = const PurchaseState();
  }
}

/// Provider for managing purchase state and transactions.
final purchaseNotifierProvider =
    StateNotifierProvider.autoDispose<PurchaseNotifier, PurchaseState>((ref) {
      final repository = ref.watch(purchaseRepositoryProvider);
      return PurchaseNotifier(repository, ref);
    });

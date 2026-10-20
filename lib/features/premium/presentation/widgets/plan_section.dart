import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/purchase_provider.dart';
import 'already_premium_card.dart';
import 'plan_card.dart';
import 'plan_card_skeleton.dart';
import 'purchase_error_banner.dart';

/// Container widget managing the subscription tier state and transactions.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// consumer container separating state from thin screen scaffold.
class PlanSection extends ConsumerWidget {
  const PlanSection({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isAlreadyPremium = currentUser?.plan == 'premium';

    if (isAlreadyPremium) {
      return const AlreadyPremiumCard();
    }

    final plansAsync = ref.watch(subscriptionPlansProvider);
    final purchaseState = ref.watch(purchaseNotifierProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (purchaseState.isError && purchaseState.errorMessage != null) ...[
          PurchaseErrorBanner(
            message: purchaseState.errorMessage!,
            onRetry: () {
              if (purchaseState.activePlanId != null) {
                _triggerPurchase(context, ref, purchaseState.activePlanId!);
              } else {
                ref.read(purchaseNotifierProvider.notifier).clearError();
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        plansAsync.when(
          loading: () => const PlanCardSkeleton(),
          error: (err, stack) => PurchaseErrorBanner(
            message: AppStrings.plansLoadError,
            onRetry: () => ref.refresh(subscriptionPlansProvider),
          ),
          data: (plans) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final plan in plans)
                PlanCard(
                  plan: plan,
                  isLoading:
                      purchaseState.isLoading &&
                      purchaseState.activePlanId == plan.id,
                  onSubscribe: () => _triggerPurchase(context, ref, plan.id),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _triggerPurchase(
    BuildContext context,
    WidgetRef ref,
    String planId,
  ) async {
    final status = await ref
        .read(purchaseNotifierProvider.notifier)
        .purchase(planId);
    if (status.name == 'success') {
      onSuccess();
    }
  }
}

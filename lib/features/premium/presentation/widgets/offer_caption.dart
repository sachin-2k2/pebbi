import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../providers/offer_provider.dart';

/// Dynamic caption for the premium card displaying trial and pricing terms.
///
/// Follows AGENTS.md §3 & §4:
/// - Watches [introductoryOfferProvider] asynchronously.
/// - Loading: displays a lightweight skeleton container without blocking screen rendering.
/// - Error/offline: gracefully renders empty space; never blocks or breaks the CTA actions.
/// - Data: renders localized ICU terms with plural-safe trial length and formatted price.
class OfferCaption extends ConsumerWidget {
  const OfferCaption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(introductoryOfferProvider);

    return offerAsync.when(
      loading: () => _buildSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (offer) {
        final text = AppStrings.premiumOfferCaption(
          trialDays: offer.trialDays,
          formattedPrice: offer.formattedPrice,
          period: offer.period,
          canWatchAdForFreeDay: offer.canWatchAdForFreeDay,
        );

        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            text,
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        height: 14.0,
        width: 240.0,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
    );
  }
}

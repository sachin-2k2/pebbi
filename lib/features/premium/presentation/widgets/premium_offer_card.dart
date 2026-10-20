import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import 'benefit_check_row.dart';
import 'offer_caption.dart';

/// Reusable premium benefit card with purple gradient background.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// flexible sizing without fixed heights, wraps gracefully at 200% text scale.
class PremiumOfferCard extends StatelessWidget {
  const PremiumOfferCard({super.key});

  static const List<String> defaultBenefits = [
    AppStrings.premiumBenefit1,
    AppStrings.premiumBenefit2,
    AppStrings.premiumBenefit3,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.premiumGradientStart,
            AppColors.premiumGradientEnd,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.premiumCardTitle,
            style: AppTypography.cardTitle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final benefit in defaultBenefits) BenefitCheckRow(text: benefit),
          const SizedBox(height: AppSpacing.xs),
          const OfferCaption(),
        ],
      ),
    );
  }
}

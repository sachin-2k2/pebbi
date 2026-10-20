import 'package:flutter/material.dart';
import '../../../../core/design_system/benefit_chip.dart';
import '../../../../core/design_system/crown_icon.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../../premium/presentation/widgets/premium_offer_card.dart';

/// Scrollable body for Onboarding Setup Step 10: Premium Offer ("You're all set").
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// flexible sizing, clamped mascot height, no fixed heights.
class PremiumOfferBody extends StatelessWidget {
  const PremiumOfferBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    final mascotSize = (screenHeight * 0.13).clamp(54.0, 104.0);
    final showMascot = screenHeight > 420.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showMascot) ...[
          const SizedBox(height: AppSpacing.sm),
          ExcludeSemantics(
            child: PebbiMascot(
              size: mascotSize,
              accentColor: AppColors.brandPurple,
              expression: PebbiExpression.surprised,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Semantics(
          header: true,
          child: Text(
            AppStrings.premiumOfferTitle,
            textAlign: TextAlign.center,
            style: AppTypography.screenTitle.copyWith(color: titleColor),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.premiumOfferSubtitle,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: subtitleColor),
        ),
        const SizedBox(height: AppSpacing.md),
        const BenefitChip(
          label: AppStrings.oneLastThing,
          tone: ChipTone.purple,
          leading: CrownIcon(color: AppColors.brandPurple),
        ),
        const SizedBox(height: AppSpacing.lg),
        const PremiumOfferCard(),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

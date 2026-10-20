import 'package:flutter/material.dart';
import '../../../../core/design_system/benefit_chip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/subscription_plan.dart';
import 'benefit_check_row.dart';
import 'plan_price_row.dart';
import 'plan_trial_line.dart';
import 'purchase_button.dart';

/// Reusable subscription plan card rendering pricing, trial, benefits, and CTA.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// reusable for multiple plans, flexible height, WCAG AA compliant.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.onSubscribe,
    this.isLoading = false,
  });

  final SubscriptionPlan plan;
  final VoidCallback onSubscribe;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final checkTextColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: isDark ? null : AppSpacing.cardShadow,
        border: isDark
            ? Border.all(color: AppColors.darkBorder, width: 1.0)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderRow(isDark),
          const SizedBox(height: AppSpacing.sm),
          PlanPriceRow(
            formattedPrice: plan.formattedPrice,
            billingPeriod: plan.billingPeriod,
          ),
          if (plan.trialEligible && plan.trialDays > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            PlanTrialLine(
              trialDays: plan.trialDays,
              isEligible: plan.trialEligible,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          for (final benefit in plan.benefits)
            BenefitCheckRow(
              text: benefit,
              textColor: checkTextColor,
              iconColor: AppColors.mint,
            ),
          const SizedBox(height: AppSpacing.lg),
          PurchaseButton(
            isLoading: isLoading,
            trialEligible: plan.trialEligible,
            onPressed: onSubscribe,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(bool isDark) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        Text(
          plan.title,
          style: AppTypography.cardTitle.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        if (plan.isMostPopular)
          const BenefitChip(
            label: AppStrings.mostPopularPill,
            tone: ChipTone.purple,
            showDefaultIcon: false,
          ),
      ],
    );
  }
}

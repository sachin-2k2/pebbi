import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Displays plan price and billing period, wrapping cleanly without overflow.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// Wrap layout allows long foreign currencies and 200% scale to wrap cleanly.
class PlanPriceRow extends StatelessWidget {
  const PlanPriceRow({
    super.key,
    required this.formattedPrice,
    required this.billingPeriod,
  });

  final String formattedPrice;
  final String billingPeriod;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final priceColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final periodColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        Text(
          formattedPrice,
          style: AppTypography.display.copyWith(
            fontSize: 34.0,
            fontWeight: FontWeight.w800,
            color: priceColor,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          AppStrings.billingPeriodSuffix(billingPeriod),
          style: AppTypography.bodyLarge.copyWith(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: periodColor,
          ),
        ),
      ],
    );
  }
}

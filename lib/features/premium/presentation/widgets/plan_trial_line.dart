import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Introductory trial sentence with WCAG AA compliant green contrast.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// wraps gracefully at 200% scale, hides when user is not trial eligible.
///
/// TODO(question): Verify claim "cancel any time, in one tap" with legal team.
/// Subscriptions must be cancelled in device store settings rather than a 1-tap in-app button.
class PlanTrialLine extends StatelessWidget {
  const PlanTrialLine({
    super.key,
    required this.trialDays,
    this.isEligible = true,
  });

  final int trialDays;
  final bool isEligible;

  @override
  Widget build(BuildContext context) {
    if (!isEligible || trialDays <= 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // WCAG AA compliant green: #047857 (4.84:1) in light mode, #34D399 (8.44:1) in dark mode
    final textColor = isDark
        ? AppColors.darkChipMintText
        : AppColors.successTextHeader;

    return Text(
      AppStrings.trialDaysLine(trialDays),
      style: AppTypography.bodyMedium.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Mint pill badge showing total earned badge count with WCAG AA contrast.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.6.
class EarnedCountPill extends StatelessWidget {
  const EarnedCountPill({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkRewardsPillMintBackground
        : AppColors.rewardsPillMintBackground;
    final text = isDark
        ? AppColors.darkRewardsPillMintText
        : AppColors.rewardsPillMintText;

    return Semantics(
      label: AppStrings.rewardsBadgesEarnedCount(count),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 4.0,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Text(
          AppStrings.rewardsBadgesEarnedCount(count),
          style: AppTypography.caption.copyWith(
            color: text,
            fontWeight: FontWeight.w700,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Calm status card displayed when the active learner already has a premium subscription.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines.
///
/// TODO(question): Full design for already-premium state (manage tier, renewal date)
/// was not provided in the visual screenshot.
class AlreadyPremiumCard extends StatelessWidget {
  const AlreadyPremiumCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkSurface : AppColors.surface;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: const BoxDecoration(
              color: AppColors.tintMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.mintDepth,
              size: 28.0,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.alreadyPremiumTitle,
            style: AppTypography.cardTitle.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.alreadyPremiumSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

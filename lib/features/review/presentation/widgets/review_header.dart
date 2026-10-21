import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Top header row of the Review screen with title, subtitle, and compact '+' button.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.6.
class ReviewHeader extends StatelessWidget {
  const ReviewHeader({super.key, required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.reviewPhrasesLearnedTitle,
                style: AppTypography.screenTitle.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 26.0,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppStrings.reviewPhrasesLearnedSubtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: subtitleColor,
                  fontSize: 14.0,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Button3D.compactSquare(
            label: AppStrings.addPhraseTooltip,
            icon: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 26.0,
            ),
            onPressed: onAddPressed,
          ),
        ),
      ],
    );
  }
}

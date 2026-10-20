import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import 'hear_it_button.dart';

/// Prompt area for picture-based exercises:
/// Title ("Pick the picture"), prompt phrase, and "Hear it" pill button.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// centered alignment, wraps at 200% text scale without overflow.
class ExercisePrompt extends StatelessWidget {
  const ExercisePrompt({
    super.key,
    required this.prompt,
    required this.onHearIt,
    this.title = AppStrings.pickThePictureTitle,
  });

  final String title;
  final String prompt;
  final VoidCallback onHearIt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final promptColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.screenTitle.copyWith(
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            prompt,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: promptColor,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          HearItButton(onPressed: onHearIt),
        ],
      ),
    );
  }
}

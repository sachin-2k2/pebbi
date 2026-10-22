import 'package:flutter/material.dart';
import '../../../../../../core/design_system/button_3d.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';
import '../../../../domain/exercise.dart';

/// Clearly marked placeholder for speaking exercises (Item 12, Part 2).
///
/// Follows AGENTS.md §3 & §4: under 90 lines, build under 50 lines.
class SpeakingPlaceholderBody extends StatelessWidget {
  const SpeakingPlaceholderBody({
    super.key,
    required this.exercise,
    required this.onContinue,
  });

  final SpeakingPlaceholderExercise exercise;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: AppColors.brandPurple.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mic_rounded,
                  size: 56.0,
                  color: AppColors.brandPurple,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  AppStrings.speakingPlaceholderTitle,
                  style: AppTypography.screenTitle.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  exercise.placeholderMessage,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Button3D(
            label: AppStrings.continueExercise,
            backgroundColor: AppColors.brandPurple,
            depthColor: AppColors.brandPurpleDepth,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

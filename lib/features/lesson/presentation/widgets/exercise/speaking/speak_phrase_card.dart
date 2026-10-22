import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../hear_it_button.dart';

/// Top rounded card displaying the phrase to speak, its meaning, and a Hear It pill.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// responsive padding, supports dark mode and large text scaling.
class SpeakPhraseCard extends StatelessWidget {
  const SpeakPhraseCard({
    super.key,
    required this.phrase,
    required this.meaning,
    this.helperLine,
    required this.onHearIt,
  });

  final String phrase;
  final String meaning;
  final String? helperLine;
  final VoidCallback onHearIt;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurfaceVariant : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border, width: 1.5),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.brandPurple.withValues(alpha: 0.04),
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            phrase,
            style: AppTypography.screenTitle.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          if (helperLine != null && helperLine!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              helperLine!,
              style: AppTypography.caption.copyWith(
                color: AppColors.brandPurple,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.xs + 2.0),
          Text(
            meaning,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          HearItButton(onPressed: onHearIt),
        ],
      ),
    );
  }
}

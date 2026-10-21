import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/correction_style.dart';
import 'correction_helper_text.dart';
import 'correction_style_selector.dart';

/// Grey-lavender card hosting the correction style label, selector pills, and helper line.
///
/// Follows AGENTS.md §3 (<100 lines), §4.6, and WCAG AA/AAA contrast standards.
class CorrectionStyleCard extends StatelessWidget {
  const CorrectionStyleCard({
    super.key,
    required this.selectedStyle,
    required this.onStyleSelected,
  });

  final CorrectionStyle selectedStyle;
  final ValueChanged<CorrectionStyle> onStyleSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? AppColors.darkCorrectionCardBackground
        : AppColors.correctionCardBackground;
    final labelColor = isDark
        ? AppColors.darkCorrectionLabelMuted
        : AppColors.correctionLabelMuted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Uppercase Category Overline Label (WCAG AA: 5.2:1 contrast)
          Text(
            AppStrings.correctionStyleLabel,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: labelColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Correction Style Pills
          CorrectionStyleSelector(
            selectedStyle: selectedStyle,
            onStyleSelected: onStyleSelected,
          ),
          const SizedBox(height: AppSpacing.md),
          // Animated Dynamic Helper Line
          CorrectionHelperText(style: selectedStyle),
        ],
      ),
    );
  }
}

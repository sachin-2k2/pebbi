import 'package:flutter/material.dart';
import '../../../../../core/layout/adaptive_sheet.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Modal sheet displaying the grammatical or conversational explanation for the question.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// uses AdaptiveSheet, responsive width on tablets.
class WhySheet extends StatelessWidget {
  const WhySheet({super.key, required this.explanation});

  final String explanation;

  /// Shows the why sheet adaptively on [context].
  static Future<void> show(BuildContext context, String explanation) {
    // TODO(question): Full design for the "Why?" explanation sheet is not provided.
    // Verify with client whether to include culture notes, audio playback, or vocabulary chips.
    return AdaptiveSheet.show(
      context: context,
      builder: (sheetContext) => WhySheet(explanation: explanation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.whySheetTitle,
                style: AppTypography.cardTitle.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            explanation,
            style: AppTypography.bodyLarge.copyWith(
              height: 1.5,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

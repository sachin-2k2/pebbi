import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/layout/adaptive_sheet.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Confirmation sheet shown when tapping X or pressing the system back button.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// uses AdaptiveSheet, responsive width on tablets.
class ExitConfirmSheet extends StatelessWidget {
  const ExitConfirmSheet({super.key});

  /// Shows the exit confirmation sheet adaptively.
  /// Returns `true` if the user confirms leaving, `false` otherwise.
  static Future<bool> show(BuildContext context) async {
    // TODO(question): Confirm exact copy and whether partial progress is retained or discarded.
    final result = await AdaptiveSheet.show<bool>(
      context: context,
      builder: (sheetContext) => const ExitConfirmSheet(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.exitConfirmTitle,
            textAlign: TextAlign.center,
            style: AppTypography.cardTitle.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.exitConfirmBody,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Button3D(
            label: AppStrings.exitConfirmStay,
            backgroundColor: AppColors.brandPurple,
            depthColor: AppColors.brandPurpleDepth,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              minimumSize: const Size(
                double.infinity,
                AppSpacing.minTouchTarget,
              ),
            ),
            child: Text(
              AppStrings.exitConfirmLeave,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

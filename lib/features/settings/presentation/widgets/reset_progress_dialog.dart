import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Destructive confirmation dialog for resetting user progress.
///
/// Follows AGENTS.md §3 & §6: default focus on Cancel, explains local wipe, red action.
class ResetProgressDialog extends StatelessWidget {
  const ResetProgressDialog({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) =>
          ResetProgressDialog(onConfirm: () => Navigator.of(context).pop(true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final redColor = isDark
        ? AppColors.darkDestructiveText
        : AppColors.destructiveText;

    return AlertDialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      title: Text(
        AppStrings.settingsResetDialogTitle,
        style: AppTypography.cardTitle.copyWith(
          color: titleColor,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Text(
        AppStrings.settingsResetDialogBody,
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            AppStrings.settingsResetCancel,
            style: AppTypography.labelLarge.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            AppStrings.settingsResetConfirm,
            style: AppTypography.labelLarge.copyWith(
              color: redColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

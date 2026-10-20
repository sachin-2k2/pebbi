import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';

/// Top-left close button for the "Show Your Screen" emergency overlay.
class ShowScreenCloseButton extends StatelessWidget {
  const ShowScreenCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.close,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            Icons.close_rounded,
            size: 28,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Full-width Check button with flat pale lavender disabled state (Screenshot 1)
/// and full 3D Mint enabled state (Screenshot 2).
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// 48dp minimum touch target, accessible disabled semantics.
class CheckButton extends StatelessWidget {
  const CheckButton({
    super.key,
    required this.onPressed,
    required this.isEnabled,
  });

  final VoidCallback? onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) {
      return Semantics(
        button: true,
        enabled: false,
        excludeSemantics: true,
        label: AppStrings.checkDisabledSemantics,
        child: Container(
          width: double.infinity,
          height: AppSpacing.buttonHeightMd,
          decoration: BoxDecoration(
            color: const Color(0xFFE9E5F7), // Flat pale lavender
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          alignment: Alignment.center,
          child: Text(
            AppStrings.check,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFFA197CC), // Muted lavender-purple
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Button3D(
        label: AppStrings.check,
        backgroundColor: AppColors.mint,
        depthColor: AppColors.mintDepth,
        textColor: Colors.white,
        isFullWidth: true,
        onPressed: onPressed,
      ),
    );
  }
}

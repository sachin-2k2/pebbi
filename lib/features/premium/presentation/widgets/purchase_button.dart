import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_strings.dart';

/// Purchase action button wrapping Button3D with loading and trial states.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// 48dp minimum tap target, accessible state announcements.
class PurchaseButton extends StatelessWidget {
  const PurchaseButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.trialEligible = true,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final bool trialEligible;

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = isLoading
        ? AppStrings.purchaseProcessing
        : (trialEligible
              ? AppStrings.startMyFreeWeek
              : AppStrings.subscribeAction);

    return Semantics(
      button: true,
      enabled: !isLoading,
      label: effectiveLabel,
      child: Button3D(
        label: effectiveLabel,
        backgroundColor: AppColors.mint,
        depthColor: AppColors.mintDepth,
        textColor: Colors.white,
        isFullWidth: true,
        icon: isLoading
            ? const SizedBox(
                width: 18.0,
                height: 18.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : null,
        onPressed: isLoading ? null : onPressed,
      ),
    );
  }
}

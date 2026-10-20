import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Pinned bottom button area for onboarding setup steps with optional
/// secondary text action (e.g. "I'm brand new — start me at Little").
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// flexible sizing with full-width Button3D, minimum 48dp secondary tap target.
class StepFooterButton extends StatelessWidget {
  const StepFooterButton({
    super.key,
    required this.onPressed,
    this.label = AppStrings.continueAction,
    this.isEnabled = true,
    this.backgroundColor = AppColors.mint,
    this.depthColor = AppColors.mintDepth,
    this.secondaryLabel,
    this.onSecondaryPressed,
    this.secondarySemanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final Color backgroundColor;
  final Color depthColor;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final String? secondarySemanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Button3D(
          label: label,
          backgroundColor: backgroundColor,
          depthColor: depthColor,
          textColor: Colors.white,
          isFullWidth: true,
          onPressed: isEnabled ? onPressed : null,
        ),
        if (secondaryLabel != null && onSecondaryPressed != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Semantics(
            button: true,
            label: secondarySemanticsLabel ?? secondaryLabel,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSecondaryPressed,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppSpacing.minTouchTarget,
                    minWidth: AppSpacing.minTouchTarget,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Center(
                      child: Text(
                        secondaryLabel!,
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

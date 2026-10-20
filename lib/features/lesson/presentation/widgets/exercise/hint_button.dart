import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Text button with lightbulb icon that removes one wrong option from the grid.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// 48dp minimum touch target, accessible disabled semantics.
class HintButton extends StatelessWidget {
  const HintButton({super.key, required this.onPressed, this.isEnabled = true});

  final VoidCallback? onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = isDark
        ? AppColors.brandPurpleLight
        : AppColors.brandPurple;
    final disabledColor = isDark
        ? AppColors.darkBorder
        : AppColors.disabledText;
    final color = isEnabled ? activeColor : disabledColor;

    return Semantics(
      button: true,
      enabled: isEnabled,
      excludeSemantics: !isEnabled,
      label: isEnabled
          ? AppStrings.hintSemantics
          : AppStrings.hintDisabledSemantics,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
              minWidth: AppSpacing.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, size: 18.0, color: color),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    AppStrings.hint,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

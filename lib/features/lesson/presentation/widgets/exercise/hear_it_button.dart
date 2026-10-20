import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Pill button with a speaker icon and "Hear it" label.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// 48dp minimum touch target, accessible audio semantics.
class HearItButton extends StatelessWidget {
  const HearItButton({
    super.key,
    required this.onPressed,
    this.label = AppStrings.hearIt,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.tintLavender.withValues(alpha: 0.5);
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final textStyle = AppTypography.caption.copyWith(
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
    );

    return Semantics(
      button: true,
      label: AppStrings.hearItSemantics,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
              minWidth: 90.0,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md + 2.0,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: border, width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.volume_up_rounded,
                  size: 18.0,
                  color: isDark
                      ? AppColors.brandPurpleLight
                      : AppColors.brandPurple,
                ),
                const SizedBox(width: AppSpacing.xs + 2.0),
                Text(label, style: textStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

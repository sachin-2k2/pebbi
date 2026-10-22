import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Destructive settings row displaying the red "Reset my progress" action.
///
/// Follows AGENTS.md §3 & WCAG AA: >5.2:1 contrast red title on lavender background.
class DestructiveTile extends StatelessWidget {
  const DestructiveTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkSettingsTileBackground
        : AppColors.settingsTileBackground;
    final borderColor = isDark
        ? AppColors.darkSettingsTileBorder
        : AppColors.settingsTileBorder;
    final redColor = isDark
        ? AppColors.darkDestructiveText
        : AppColors.destructiveText;
    final descColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Semantics(
      button: true,
      label:
          '${AppStrings.settingsResetProgressTitle}, ${AppStrings.settingsResetProgressSubtitle}. Double tap to reset.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56.0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38.0,
                  height: 38.0,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 20.0,
                    color: redColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.settingsResetProgressTitle,
                        style: AppTypography.labelLarge.copyWith(
                          color: redColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        AppStrings.settingsResetProgressSubtitle,
                        style: AppTypography.captionSmall.copyWith(
                          color: descColor,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20.0, color: descColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

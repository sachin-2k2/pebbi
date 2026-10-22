import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable settings row that displays a trailing value/selector and triggers a picker on tap.
///
/// Follows AGENTS.md §3 & §4: minimum 48dp touch target, accessible announcements.
class SettingsPickerTile extends StatelessWidget {
  const SettingsPickerTile({
    super.key,
    this.leading,
    required this.title,
    this.description,
    required this.trailingText,
    this.trailingIcon,
    required this.onTap,
    this.isEnabled = true,
  });

  final Widget? leading;
  final String title;
  final String? description;
  final String trailingText;
  final IconData? trailingIcon;
  final VoidCallback onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final descColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final trailingBg = isDark
        ? AppColors.darkSettingsTileBackground
        : AppColors.settingsTileBackground;
    final trailingBorder = isDark
        ? AppColors.darkSettingsTileBorder
        : AppColors.settingsTileBorder;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: '$title, $trailingText. Double tap to change.',
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.45,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTypography.labelLarge.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 2.0),
                        Text(
                          description!,
                          style: AppTypography.captionSmall.copyWith(
                            color: descColor,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  constraints: const BoxConstraints(minHeight: 38.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: trailingBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    border: Border.all(color: trailingBorder, width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trailingText,
                        style: AppTypography.labelMedium.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: 4.0),
                        Icon(trailingIcon, size: 16.0, color: descColor),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

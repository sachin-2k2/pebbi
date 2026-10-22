import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Interactive tile in the Sound and Haptics card that tests sound and haptic output.
///
/// Follows AGENTS.md §3 & §4: minimum 48dp tap target, WCAG AA contrast.
class TestSoundTile extends StatelessWidget {
  const TestSoundTile({
    super.key,
    required this.isSoundEnabled,
    required this.onTestSound,
  });

  final bool isSoundEnabled;
  final VoidCallback onTestSound;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkSettingsTileBackground
        : AppColors.settingsTileBackground;
    final borderColor = isDark
        ? AppColors.darkSettingsTileBorder
        : AppColors.settingsTileBorder;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final iconBg = isDark ? AppColors.darkSurface : Colors.white;

    return Semantics(
      button: true,
      label: '${AppStrings.settingsTestSoundTitle}. Double tap to test.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isSoundEnabled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.settingsSoundEffectsOffMessage),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              onTestSound();
            }
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52.0),
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
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.volume_up_rounded,
                    size: 20.0,
                    color: AppColors.brandPurple,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    AppStrings.settingsTestSoundTitle,
                    style: AppTypography.labelLarge.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.0,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

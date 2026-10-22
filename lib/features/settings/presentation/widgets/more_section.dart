import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import 'settings_info_tile.dart';
import 'settings_section_card.dart';

/// More section card navigating to Privacy, Help, and About placeholder pages.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines, tokens.
class MoreSection extends StatelessWidget {
  const MoreSection({
    super.key,
    required this.onPrivacyTap,
    required this.onHelpTap,
    required this.onAboutTap,
  });

  final VoidCallback onPrivacyTap;
  final VoidCallback onHelpTap;
  final VoidCallback onAboutTap;

  Widget _buildIconBox(IconData icon, Color color, bool isDark) {
    return Container(
      width: 38.0,
      height: 38.0,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20.0, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chevronColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return SettingsSectionCard(
      emoji: '📗',
      title: AppStrings.settingsMoreTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsInfoTile(
            icon: _buildIconBox(
              Icons.privacy_tip_outlined,
              AppColors.coral,
              isDark,
            ),
            title: AppStrings.settingsPrivacyTitle,
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 20.0,
              color: chevronColor,
            ),
            onTap: onPrivacyTap,
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsInfoTile(
            icon: _buildIconBox(
              Icons.help_outline_rounded,
              AppColors.accentSky,
              isDark,
            ),
            title: AppStrings.settingsHelpTitle,
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 20.0,
              color: chevronColor,
            ),
            onTap: onHelpTap,
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsInfoTile(
            icon: _buildIconBox(
              Icons.info_outline_rounded,
              AppColors.brandPurple,
              isDark,
            ),
            title: AppStrings.settingsAboutTitle,
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 20.0,
              color: chevronColor,
            ),
            onTap: onAboutTap,
          ),
        ],
      ),
    );
  }
}

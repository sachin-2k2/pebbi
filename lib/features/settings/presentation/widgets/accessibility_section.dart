import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import 'settings_section_card.dart';
import 'settings_toggle_tile.dart';

/// Accessibility section card controlling reduced motion, captions, and left-handed layout.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines, tokens.
class AccessibilitySection extends StatelessWidget {
  const AccessibilitySection({
    super.key,
    required this.reduceMotion,
    required this.onReduceMotionChanged,
    required this.captionsAlwaysOn,
    required this.onCaptionsChanged,
    required this.isLeftHanded,
    required this.onLeftHandedChanged,
  });

  final bool reduceMotion;
  final ValueChanged<bool> onReduceMotionChanged;
  final bool captionsAlwaysOn;
  final ValueChanged<bool> onCaptionsChanged;
  final bool isLeftHanded;
  final ValueChanged<bool> onLeftHandedChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      emoji: '♿',
      title: AppStrings.settingsAccessibilityTitle,
      subtitle: AppStrings.settingsAccessibilitySubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsToggleTile(
            leading: const Icon(
              Icons.blur_on_rounded,
              size: 20.0,
              color: AppColors.accentSky,
            ),
            title: AppStrings.settingsReduceMotionTitle,
            value: reduceMotion,
            onChanged: onReduceMotionChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          SettingsToggleTile(
            leading: const Icon(
              Icons.subtitles_rounded,
              size: 20.0,
              color: AppColors.brandPurple,
            ),
            title: AppStrings.settingsCaptionsTitle,
            description: AppStrings.settingsCaptionsSubtitle,
            value: captionsAlwaysOn,
            onChanged: onCaptionsChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          SettingsToggleTile(
            leading: const Text('🖐️', style: TextStyle(fontSize: 18.0)),
            title: AppStrings.settingsLeftHandedTitle,
            description: AppStrings.settingsLeftHandedSubtitle,
            value: isLeftHanded,
            onChanged: onLeftHandedChanged,
          ),
        ],
      ),
    );
  }
}

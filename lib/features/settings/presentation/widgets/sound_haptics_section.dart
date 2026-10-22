import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import 'settings_section_card.dart';
import 'settings_toggle_tile.dart';
import 'test_sound_tile.dart';

/// Sound and haptics card managing audio feedback, vibrations, and speaking tasks.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines, responsive constraints.
class SoundHapticsSection extends StatelessWidget {
  const SoundHapticsSection({
    super.key,
    required this.soundEnabled,
    required this.onSoundEnabledChanged,
    required this.hapticsEnabled,
    required this.onHapticsEnabledChanged,
    required this.autoplayEnabled,
    required this.onAutoplayChanged,
    required this.speakingPracticeEnabled,
    required this.onSpeakingPracticeChanged,
    required this.onTestSound,
  });

  final bool soundEnabled;
  final ValueChanged<bool> onSoundEnabledChanged;
  final bool hapticsEnabled;
  final ValueChanged<bool> onHapticsEnabledChanged;
  final bool autoplayEnabled;
  final ValueChanged<bool> onAutoplayChanged;
  final bool speakingPracticeEnabled;
  final ValueChanged<bool> onSpeakingPracticeChanged;
  final VoidCallback onTestSound;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      emoji: '🔔',
      title: AppStrings.settingsSoundHapticsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsToggleTile(
            leading: const Icon(
              Icons.music_note_rounded,
              size: 20.0,
              color: AppColors.brandPurple,
            ),
            title: AppStrings.settingsSoundEffectsTitle,
            value: soundEnabled,
            onChanged: onSoundEnabledChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          SettingsToggleTile(
            leading: const Icon(
              Icons.vibration_rounded,
              size: 20.0,
              color: AppColors.coral,
            ),
            title: AppStrings.settingsHapticsTitle,
            description: AppStrings.settingsHapticsSubtitle,
            value: hapticsEnabled,
            onChanged: onHapticsEnabledChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          SettingsToggleTile(
            leading: const Icon(
              Icons.play_circle_outline_rounded,
              size: 20.0,
              color: AppColors.accentSky,
            ),
            title: AppStrings.settingsAutoplayTitle,
            description: AppStrings.settingsAutoplaySubtitle,
            value: autoplayEnabled,
            onChanged: onAutoplayChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          SettingsToggleTile(
            leading: const Icon(
              Icons.mic_none_rounded,
              size: 20.0,
              color: AppColors.mint,
            ),
            title: AppStrings.settingsSpeakingTitle,
            description: AppStrings.settingsSpeakingSubtitle,
            value: speakingPracticeEnabled,
            onChanged: onSpeakingPracticeChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          TestSoundTile(isSoundEnabled: soundEnabled, onTestSound: onTestSound),
        ],
      ),
    );
  }
}

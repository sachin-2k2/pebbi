import 'package:flutter/material.dart';
import '../../../../core/design_system/accent_swatch_row.dart';
import '../../../../core/design_system/segmented_tabs.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../../onboarding/domain/accent_option.dart';
import '../../domain/text_size_rules.dart';
import 'settings_section_card.dart';
import 'text_size_slider.dart';

/// Appearance section card managing app theme mode, accent color, and text scale.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines, live theme wiring.
class AppearanceSection extends StatelessWidget {
  const AppearanceSection({
    super.key,
    required this.selectedThemeMode,
    required this.onThemeModeChanged,
    required this.selectedAccentId,
    required this.onAccentChanged,
    required this.textScale,
    required this.onTextScaleChanged,
  });

  final String selectedThemeMode;
  final ValueChanged<String> onThemeModeChanged;
  final String selectedAccentId;
  final ValueChanged<String> onAccentChanged;
  final double textScale;
  final ValueChanged<double> onTextScaleChanged;

  static const List<String> themeModes = ['light', 'dark', 'system'];

  String _themeLabel(String mode) {
    switch (mode) {
      case 'dark':
        return AppStrings.settingsThemeDark;
      case 'system':
        return AppStrings.settingsThemeSystem;
      case 'light':
      default:
        return AppStrings.settingsThemeLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final titleColor = palette.textPrimary;
    final descColor = palette.textMuted;
    final accentOption = AccentOption.findById(selectedAccentId);
    final accentColor = Color(accentOption.colorValue);

    return SettingsSectionCard(
      emoji: '🎨',
      title: AppStrings.settingsAppearanceTitle,
      subtitle: AppStrings.settingsAppearanceSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedTabs<String>(
            items: themeModes,
            selectedItem: selectedThemeMode,
            onSelected: onThemeModeChanged,
            labelBuilder: _themeLabel,
            semanticsLabelBuilder: (item, index, total, isSelected) =>
                '${_themeLabel(item)}, tab $index of $total',
          ),
          const SizedBox(height: AppSpacing.lg),
          AccentSwatchRow(
            selectedAccentId: selectedAccentId,
            onSelectAccent: onAccentChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.settingsTextSizeLabel,
                style: AppTypography.labelLarge.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                TextSizeRules.formatPercent(textScale),
                style: AppTypography.labelMedium.copyWith(
                  color: descColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextSizeSlider(
            currentScale: textScale,
            activeColor: accentColor,
            onChanged: onTextScaleChanged,
          ),
        ],
      ),
    );
  }
}

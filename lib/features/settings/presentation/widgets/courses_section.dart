import 'package:flutter/material.dart';
import '../../../../core/design_system/notice_banner.dart';
import '../../../../core/design_system/selectable_pill_chip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../../onboarding/data/mock_language_repository.dart';
import '../../../onboarding/domain/language_level.dart';
import '../../../onboarding/domain/language_option.dart';
import '../../../onboarding/domain/level_info.dart';
import 'explanation_language_sheet.dart';
import 'settings_picker_tile.dart';
import 'settings_section_card.dart';
import 'settings_toggle_tile.dart';

/// Courses section card allowing immediate language, level, and helper line adjustments.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines, responsive wrap.
class CoursesSection extends StatelessWidget {
  const CoursesSection({
    super.key,
    required this.selectedTargetLanguageCode,
    required this.onTargetLanguageChanged,
    required this.selectedLevel,
    required this.onLevelChanged,
    required this.selectedExplanationLanguageCode,
    required this.onExplanationLanguageChanged,
    required this.showHelperLine,
    required this.onShowHelperLineChanged,
  });

  final String selectedTargetLanguageCode;
  final ValueChanged<String> onTargetLanguageChanged;
  final LanguageLevel selectedLevel;
  final ValueChanged<LanguageLevel> onLevelChanged;
  final String selectedExplanationLanguageCode;
  final ValueChanged<String> onExplanationLanguageChanged;
  final bool showHelperLine;
  final ValueChanged<bool> onShowHelperLineChanged;

  static const List<Map<String, String>> availableLanguages = [
    {'code': 'es', 'name': 'Español'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'ar', 'name': 'العربية'},
  ];

  LanguageOption get _activeExplanationOption {
    final list = MockLanguageRepository.defaultLanguages;
    return list.firstWhere(
      (l) => l.code == selectedExplanationLanguageCode,
      orElse: () => list.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final expLang = _activeExplanationOption;
    final showNotice = !expLang.translationsReviewed;

    return SettingsSectionCard(
      emoji: '🌍',
      title: AppStrings.settingsCoursesTitle,
      subtitle: AppStrings.settingsCoursesSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final lang in availableLanguages)
                SelectablePillChip(
                  label: lang['name']!,
                  isSelected: selectedTargetLanguageCode == lang['code'],
                  onTap: () => onTargetLanguageChanged(lang['code']!),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final info in LevelInfo.allLevels)
                SelectablePillChip(
                  label: info.name,
                  isSelected: selectedLevel == info.level,
                  onTap: () => onLevelChanged(info.level),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsPickerTile(
            leading: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 20.0,
              color: AppColors.brandPurple,
            ),
            title: AppStrings.settingsExplanationsInTitle,
            description: AppStrings.settingsExplanationsInSubtitle,
            trailingText: expLang.englishName,
            trailingIcon: Icons.keyboard_arrow_down_rounded,
            onTap: () => ExplanationLanguageSheet.show(
              context: context,
              selectedCode: selectedExplanationLanguageCode,
              onSelected: onExplanationLanguageChanged,
            ),
          ),
          if (showNotice) ...[
            const SizedBox(height: AppSpacing.xs),
            const NoticeBanner(message: AppStrings.translationsPendingNotice),
          ],
          const SizedBox(height: AppSpacing.sm),
          SettingsToggleTile(
            leading: const Icon(
              Icons.subtitles_outlined,
              size: 20.0,
              color: AppColors.accentSky,
            ),
            title: AppStrings.settingsShowHelperLineTitle,
            description: AppStrings.settingsShowHelperLineSubtitle,
            value: showHelperLine,
            onChanged: onShowHelperLineChanged,
          ),
        ],
      ),
    );
  }
}

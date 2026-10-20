import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/language_option.dart';
import 'language_chip.dart';

/// Responsive wrapping flow layout for language selection chips.
///
/// Follows AGENTS.md §3 and §4: under 100 lines, no fixed column count,
/// automatically adapts to any screen width and text scale.
class LanguageChipWrap extends StatelessWidget {
  const LanguageChipWrap({
    super.key,
    required this.languages,
    required this.selectedCode,
    required this.onSelect,
  });

  final List<LanguageOption> languages;
  final String selectedCode;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (languages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: Text(
            AppStrings.noLanguagesFound,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final language in languages)
          LanguageChip(
            language: language,
            isSelected: language.code == selectedCode,
            onTap: () => onSelect(language.code),
          ),
      ],
    );
  }
}

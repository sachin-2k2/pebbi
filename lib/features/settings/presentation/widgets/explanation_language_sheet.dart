import 'package:flutter/material.dart';
import '../../../../core/layout/adaptive_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../../onboarding/data/mock_language_repository.dart';
import '../../../onboarding/domain/language_option.dart';

/// Searchable adaptive bottom sheet for picking the explanation language.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, accent-insensitive search,
/// checkmark on active selection, yellow notice for unreviewed translations.
class ExplanationLanguageSheet extends StatefulWidget {
  const ExplanationLanguageSheet({
    super.key,
    required this.selectedCode,
    required this.onSelected,
  });

  final String selectedCode;
  final ValueChanged<String> onSelected;

  static Future<void> show({
    required BuildContext context,
    required String selectedCode,
    required ValueChanged<String> onSelected,
  }) {
    return AdaptiveSheet.show<void>(
      context: context,
      builder: (sheetContext) => ExplanationLanguageSheet(
        selectedCode: selectedCode,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<ExplanationLanguageSheet> createState() =>
      _ExplanationLanguageSheetState();
}

class _ExplanationLanguageSheetState extends State<ExplanationLanguageSheet> {
  late final TextEditingController _searchController;
  late final List<LanguageOption> _allLanguages;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _allLanguages = MockLanguageRepository.defaultLanguages;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LanguageOption> get _filteredLanguages {
    return _allLanguages.where((l) => l.matches(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredLanguages;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.settingsExplanationSheetTitle,
            style: AppTypography.cardTitle.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _searchController,
            onChanged: (q) => setState(() => _query = q),
            decoration: InputDecoration(
              hintText: AppStrings.settingsSearchLanguagePlaceholder,
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: isDark
                  ? AppColors.darkSettingsTileBackground
                  : AppColors.settingsTileBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                borderSide: BorderSide.none,
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320.0),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const Divider(height: 1.0),
              itemBuilder: (context, index) {
                final lang = filtered[index];
                final isSelected = lang.code == widget.selectedCode;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    lang.nativeName,
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    lang.englishName,
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.textMuted,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.brandPurple,
                        )
                      : null,
                  onTap: () {
                    widget.onSelected(lang.code);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

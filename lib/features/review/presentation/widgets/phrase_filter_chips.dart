import 'package:flutter/material.dart';
import '../../../../core/design_system/selectable_pill_chip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/phrase_filter.dart';

/// Row of filter chips (All, Tricky, New, Saved) for filtering learned phrases.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.6.
class PhraseFilterChips extends StatelessWidget {
  const PhraseFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final PhraseFilter selectedFilter;
  final ValueChanged<PhraseFilter> onFilterSelected;

  String _filterLabel(PhraseFilter filter) {
    switch (filter) {
      case PhraseFilter.all:
        return AppStrings.filterAll;
      case PhraseFilter.tricky:
        return AppStrings.filterTricky;
      case PhraseFilter.newPhrases:
        return AppStrings.filterNew;
      case PhraseFilter.saved:
        return AppStrings.filterSaved;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: PhraseFilter.values.map((filter) {
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: SelectablePillChip(
              label: _filterLabel(filter),
              isSelected: isSelected,
              size: SelectablePillChipSize.small,
              selectedBackgroundColor: AppColors.brandPurple,
              selectedTextColor: Colors.white,
              onTap: () => onFilterSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

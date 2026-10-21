import 'package:flutter/material.dart';
import '../../../../core/design_system/empty_state.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/phrase_filter.dart';

/// Empty state widget displaying the winking Pebbi mascot and helpful explanation.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §8.
class PhrasesEmptyState extends StatelessWidget {
  const PhrasesEmptyState({super.key, this.activeFilter = PhraseFilter.all});

  final PhraseFilter activeFilter;

  @override
  Widget build(BuildContext context) {
    final isFiltered = activeFilter != PhraseFilter.all;
    final title = isFiltered
        ? AppStrings.emptyFilterTitle(activeFilter.name)
        : AppStrings.reviewEmptyTitle;
    final subtitle = isFiltered
        ? AppStrings.emptyFilterSubtitle
        : AppStrings.reviewEmptySubtitle;

    return EmptyState(
      illustration: const PebbiMascot(
        expression: PebbiExpression.winking,
        size: 84.0,
      ),
      title: title,
      subtitle: subtitle,
    );
  }
}

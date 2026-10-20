import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/learnable_language.dart';
import 'learn_language_card.dart';

/// Responsive grid of language cards adapting column count to window width.
///
/// Follows AGENTS.md §3 & §4:
/// - Adapts column count dynamically (2 on phones, 3+ on tablets/expanded).
/// - Equal height per row using IntrinsicHeight + CrossAxisAlignment.stretch.
/// - Dynamic vertical sizing prevents overflows at 200% text scale.
class LearnLanguageGrid extends StatelessWidget {
  const LearnLanguageGrid({
    super.key,
    required this.languages,
    required this.selectedCode,
    required this.onSelect,
    this.spacing = AppSpacing.md,
  });

  final List<LearnableLanguage> languages;
  final String selectedCode;
  final ValueChanged<LearnableLanguage> onSelect;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 2 columns on phones, up to 4 on tablets/desktop
        final columns = (constraints.maxWidth / 170.0).floor().clamp(2, 4);
        final rows = <List<LearnableLanguage>>[];

        for (var i = 0; i < languages.length; i += columns) {
          final end = (i + columns < languages.length)
              ? i + columns
              : languages.length;
          rows.add(languages.sublist(i, end));
        }

        return Column(
          children: [
            for (int r = 0; r < rows.length; r++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: r == rows.length - 1 ? 0 : spacing,
                ),
                child: _buildRow(rows[r], columns),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRow(List<LearnableLanguage> rowLanguages, int columns) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < columns; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Expanded(
              child: i < rowLanguages.length
                  ? LearnLanguageCard(
                      language: rowLanguages[i],
                      isSelected: rowLanguages[i].code == selectedCode,
                      onTap: () => onSelect(rowLanguages[i]),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }
}

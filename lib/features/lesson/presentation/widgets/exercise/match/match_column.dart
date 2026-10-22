import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_spacing.dart';
import 'match_card.dart';

/// Represents a card item in a match pairs column.
class MatchColumnItem {
  const MatchColumnItem({
    required this.id,
    required this.text,
    required this.isSelected,
    required this.isMatched,
    required this.isShaking,
  });

  final String id;
  final String text;
  final bool isSelected;
  final bool isMatched;
  final bool isShaking;
}

/// Column of match cards (either target phrases or meanings).
///
/// Follows AGENTS.md §3 & §4: under 80 lines.
class MatchColumn extends StatelessWidget {
  const MatchColumn({super.key, required this.items, required this.onCardTap});

  final List<MatchColumnItem> items;
  final ValueChanged<String> onCardTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          MatchCard(
            text: items[i].text,
            isSelected: items[i].isSelected,
            isMatched: items[i].isMatched,
            isShaking: items[i].isShaking,
            onTap: () => onCardTap(items[i].id),
          ),
        ],
      ],
    );
  }
}

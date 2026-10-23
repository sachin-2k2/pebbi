import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/suggestion.dart';
import 'suggestion_card.dart';

/// Container for suggested replies sitting directly above the input bar.
///
/// Follows AGENTS.md §4:
/// - Displays up to 3 suggestions in a vertical stack
/// - Automatically collapses into a horizontal scrolling strip when keyboard is open
class SuggestionList extends StatelessWidget {
  const SuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelect,
    this.isKeyboardOpen = false,
  });

  final List<Suggestion> suggestions;
  final ValueChanged<String> onSelect;
  final bool isKeyboardOpen;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final displayed = suggestions.take(3).toList();

    if (isKeyboardOpen) {
      // Collapsed horizontal scrolling row when keyboard is open
      return SizedBox(
        height: 52.0,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          scrollDirection: Axis.horizontal,
          itemCount: displayed.length,
          separatorBuilder: (_, index) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, i) {
            return IntrinsicWidth(
              child: SuggestionCard(
                suggestion: displayed[i],
                onTap: () => onSelect(displayed[i].text),
              ),
            );
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < displayed.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            SuggestionCard(
              suggestion: displayed[i],
              onTap: () => onSelect(displayed[i].text),
            ),
          ],
        ],
      ),
    );
  }
}

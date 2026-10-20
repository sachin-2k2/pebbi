import 'package:flutter/widgets.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/text_option.dart';
import 'answer_option_card.dart';

/// Vertically stacked list of answer option cards.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// maintains order specified by data, uses spacing tokens.
class AnswerOptionList extends StatelessWidget {
  const AnswerOptionList({
    super.key,
    required this.options,
    required this.selectedOptionId,
    required this.removedOptionIds,
    required this.isLocked,
    required this.onOptionSelected,
  });

  final List<TextOption> options;
  final String? selectedOptionId;
  final Set<String> removedOptionIds;
  final bool isLocked;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            AnswerOptionCard(
              option: options[i],
              number: i + 1,
              totalCount: options.length,
              isSelected: options[i].id == selectedOptionId,
              isRemoved: removedOptionIds.contains(options[i].id),
              isLocked: isLocked,
              onTap: () => onOptionSelected(options[i].id),
            ),
          ],
        ],
      ),
    );
  }
}

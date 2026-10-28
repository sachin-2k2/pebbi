import 'package:flutter/material.dart';
import 'package:peddi/core/theme/app_spacing.dart';
import 'package:peddi/features/onboarding/domain/placement_question.dart';
import 'placement_option_card.dart';

/// 2-column responsive grid of placement quiz options.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, responsive constraints.
class PlacementOptionGrid extends StatelessWidget {
  const PlacementOptionGrid({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.isAnswered,
    required this.onSelect,
  });

  final List<PlacementOption> options;
  final PlacementOption? selectedOption;
  final bool isAnswered;
  final ValueChanged<PlacementOption> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selectedOption == option;

        return PlacementOptionCard(
          key: Key('placement_option_${option.emoji}'),
          option: option,
          isSelected: isSelected,
          isAnswered: isAnswered,
          onTap: () => onSelect(option),
        );
      },
    );
  }
}

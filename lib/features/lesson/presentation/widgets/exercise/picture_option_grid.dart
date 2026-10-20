import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/picture_option.dart';
import 'picture_option_card.dart';

/// 2x2 grid of picture cards for the "Pick the picture" exercise.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// flexible sizing, token spacing, no fixed pixel card heights.
class PictureOptionGrid extends StatelessWidget {
  const PictureOptionGrid({
    super.key,
    required this.options,
    required this.selectedOptionId,
    required this.removedOptionIds,
    required this.isLocked,
    required this.onOptionSelected,
  });

  final List<PictureOption> options;
  final String? selectedOptionId;
  final Set<String> removedOptionIds;
  final bool isLocked;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: options.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.35,
        ),
        itemBuilder: (context, i) {
          final option = options[i];
          final isSelected = option.id == selectedOptionId;
          final isRemoved = removedOptionIds.contains(option.id);

          return PictureOptionCard(
            option: option,
            index: i + 1,
            total: options.length,
            isSelected: isSelected,
            isRemoved: isRemoved,
            isLocked: isLocked,
            onTap: () => onOptionSelected(option.id),
          );
        },
      ),
    );
  }
}

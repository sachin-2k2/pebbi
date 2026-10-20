import 'package:flutter/widgets.dart';
import '../../../domain/exercise.dart';
import 'exercise_prompt.dart';
import 'picture_option_grid.dart';

/// Middle body layout for "Pick the picture" exercises.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// passes plain data and callbacks down to leaf widgets.
class PickPictureBody extends StatelessWidget {
  const PickPictureBody({
    super.key,
    required this.exercise,
    required this.selectedOptionId,
    required this.removedOptionIds,
    required this.isLocked,
    required this.onOptionSelected,
    required this.onHearIt,
  });

  final PickPictureExercise exercise;
  final String? selectedOptionId;
  final Set<String> removedOptionIds;
  final bool isLocked;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onHearIt;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExercisePrompt(prompt: exercise.prompt, onHearIt: onHearIt),
        PictureOptionGrid(
          options: exercise.options,
          selectedOptionId: selectedOptionId,
          removedOptionIds: removedOptionIds,
          isLocked: isLocked,
          onOptionSelected: onOptionSelected,
        ),
      ],
    );
  }
}

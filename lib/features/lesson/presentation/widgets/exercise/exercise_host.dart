import 'package:flutter/widgets.dart';
import '../../../domain/exercise.dart';
import 'choose_meaning_body.dart';
import 'pick_picture_body.dart';
import 'sentence/build_sentence_body.dart';

/// Host widget that dispatches to the matching body widget based on [Exercise] type.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// siblings PickPictureBody, ChooseMeaningBody, and BuildSentenceBody remain decoupled.
class ExerciseHost extends StatelessWidget {
  const ExerciseHost({
    super.key,
    required this.exercise,
    required this.selectedOptionId,
    this.placedTileIds = const [],
    required this.removedOptionIds,
    required this.isLocked,
    required this.isPlayingAudio,
    required this.showHelperLine,
    required this.onOptionSelected,
    this.onPlaceTile,
    this.onRemoveTile,
    required this.onPlayAudio,
    required this.onHearIt,
  });

  final Exercise exercise;
  final String? selectedOptionId;
  final List<String> placedTileIds;
  final Set<String> removedOptionIds;
  final bool isLocked;
  final bool isPlayingAudio;
  final bool showHelperLine;
  final ValueChanged<String> onOptionSelected;
  final ValueChanged<String>? onPlaceTile;
  final ValueChanged<String>? onRemoveTile;
  final VoidCallback onPlayAudio;
  final VoidCallback onHearIt;

  @override
  Widget build(BuildContext context) {
    final current = exercise;

    if (current is PickPictureExercise) {
      return PickPictureBody(
        exercise: current,
        selectedOptionId: selectedOptionId,
        removedOptionIds: removedOptionIds,
        isLocked: isLocked,
        onOptionSelected: onOptionSelected,
        onHearIt: onHearIt,
      );
    }

    if (current is ChooseMeaningExercise) {
      return ChooseMeaningBody(
        exercise: current,
        selectedOptionId: selectedOptionId,
        removedOptionIds: removedOptionIds,
        isLocked: isLocked,
        isPlayingAudio: isPlayingAudio,
        showHelperLine: showHelperLine,
        onOptionSelected: onOptionSelected,
        onPlayAudio: onPlayAudio,
      );
    }

    if (current is BuildSentenceExercise) {
      return BuildSentenceBody(
        exercise: current,
        placedTileIds: placedTileIds,
        onPlaceTile: onPlaceTile ?? (_) {},
        onRemoveTile: onRemoveTile ?? (_) {},
        isLocked: isLocked,
      );
    }

    return const SizedBox.shrink();
  }
}

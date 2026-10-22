import 'package:flutter/widgets.dart';
import '../../../domain/exercise.dart';
import '../../../domain/phrase_token.dart';
import 'choose_meaning_body.dart';
import 'listen/listen_choose_body.dart';
import 'match/match_pairs_body.dart';
import 'new_phrase/new_phrase_card_body.dart';
import 'pick_picture_body.dart';
import 'reply/choose_reply_body.dart';
import 'sentence/build_sentence_body.dart';
import 'speaking/speak_exercise_host.dart';
import 'speaking/speaking_placeholder_body.dart';

/// Host widget that dispatches to the matching body widget based on [Exercise] type.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines.
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
    this.savedTokenIds = const {},
    this.onTokenTap,
    this.selectedTargetMatchId,
    this.selectedMeaningMatchId,
    this.matchedPairIds = const {},
    this.isWrongPairShake = false,
    this.onSelectTarget,
    this.onSelectMeaning,
    this.onCantListen,
    this.onSpeakingContinue,
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
  final Set<String> savedTokenIds;
  final ValueChanged<PhraseToken>? onTokenTap;
  final String? selectedTargetMatchId;
  final String? selectedMeaningMatchId;
  final Set<String> matchedPairIds;
  final bool isWrongPairShake;
  final ValueChanged<String>? onSelectTarget;
  final ValueChanged<String>? onSelectMeaning;
  final VoidCallback? onCantListen;
  final VoidCallback? onSpeakingContinue;

  @override
  Widget build(BuildContext context) {
    final cur = exercise;
    if (cur is SpeakExercise) return SpeakExerciseHost(exercise: cur);
    if (cur is NewPhraseCardExercise) {
      return NewPhraseCardBody(
        exercise: cur,
        savedTokenIds: savedTokenIds,
        onTokenTap: onTokenTap ?? (_) {},
      );
    }
    if (cur is PickPictureExercise) {
      return PickPictureBody(
        exercise: cur,
        selectedOptionId: selectedOptionId,
        removedOptionIds: removedOptionIds,
        isLocked: isLocked,
        onOptionSelected: onOptionSelected,
        onHearIt: onHearIt,
      );
    }
    if (cur is ChooseMeaningExercise) {
      return ChooseMeaningBody(
        exercise: cur,
        selectedOptionId: selectedOptionId,
        removedOptionIds: removedOptionIds,
        isLocked: isLocked,
        isPlayingAudio: isPlayingAudio,
        showHelperLine: showHelperLine,
        onOptionSelected: onOptionSelected,
        onPlayAudio: onPlayAudio,
      );
    }
    if (cur is MatchPairsExercise) {
      return MatchPairsBody(
        exercise: cur,
        selectedTargetId: selectedTargetMatchId,
        selectedMeaningId: selectedMeaningMatchId,
        matchedPairIds: matchedPairIds,
        isWrongPairShake: isWrongPairShake,
        onSelectTarget: onSelectTarget ?? (_) {},
        onSelectMeaning: onSelectMeaning ?? (_) {},
      );
    }
    if (cur is ListenChooseExercise) {
      return ListenChooseBody(
        exercise: cur,
        selectedOptionId: selectedOptionId,
        removedOptionIds: removedOptionIds,
        isLocked: isLocked,
        onOptionSelected: onOptionSelected,
        onCantListen: onCantListen ?? () {},
      );
    }
    if (cur is BuildSentenceExercise) {
      return BuildSentenceBody(
        exercise: cur,
        placedTileIds: placedTileIds,
        onPlaceTile: onPlaceTile ?? (_) {},
        onRemoveTile: onRemoveTile ?? (_) {},
        isLocked: isLocked,
      );
    }
    if (cur is ChooseReplyExercise) {
      return ChooseReplyBody(
        exercise: cur,
        selectedOptionId: selectedOptionId,
        removedOptionIds: removedOptionIds,
        isLocked: isLocked,
        onOptionSelected: onOptionSelected,
      );
    }
    if (cur is SpeakingPlaceholderExercise) {
      return SpeakingPlaceholderBody(
        exercise: cur,
        onContinue: onSpeakingContinue ?? () {},
      );
    }
    return const SizedBox.shrink();
  }
}

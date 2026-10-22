import 'package:flutter/material.dart';
import '../../../../../core/layout/content_width_limiter.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/exercise.dart';
import '../../providers/exercise_session_notifier.dart';
import '../../providers/exercise_session_state.dart';
import 'exercise_host.dart';

/// Scrollable body container for the active exercise.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// encapsulates clamping scroll physics and max content width limiter.
class ExerciseScrollArea extends StatelessWidget {
  const ExerciseScrollArea({
    super.key,
    required this.exercise,
    required this.state,
    required this.notifier,
    required this.isPlayingAudio,
    required this.showHelperLine,
    required this.onPlayAudio,
    required this.onSpeakingContinue,
  });

  final Exercise exercise;
  final ExerciseSessionState state;
  final ExerciseSessionNotifier notifier;
  final bool isPlayingAudio;
  final bool showHelperLine;
  final VoidCallback onPlayAudio;
  final VoidCallback onSpeakingContinue;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ContentWidthLimiter(
          maxWidth: AppSpacing.maxContentWidthCompact,
          child: ExerciseHost(
            exercise: exercise,
            selectedOptionId: state.selectedOptionId,
            placedTileIds: state.placedTileIds,
            removedOptionIds: state.removedOptionIds,
            isLocked: state.status == ExerciseStatus.checked,
            isPlayingAudio: isPlayingAudio,
            showHelperLine: showHelperLine,
            onOptionSelected: notifier.selectOption,
            onPlaceTile: notifier.placeTile,
            onRemoveTile: notifier.removeTile,
            onPlayAudio: onPlayAudio,
            onHearIt: onPlayAudio,
            savedTokenIds: state.savedTokenIds,
            onTokenTap: notifier.toggleTokenSaved,
            selectedTargetMatchId: state.selectedTargetMatchId,
            selectedMeaningMatchId: state.selectedMeaningMatchId,
            matchedPairIds: state.matchedPairIds,
            isWrongPairShake: state.isWrongPairShake,
            onSelectTarget: (id) =>
                notifier.selectMatchCard(id: id, isTargetColumn: true),
            onSelectMeaning: (id) =>
                notifier.selectMatchCard(id: id, isTargetColumn: false),
            onCantListen: notifier.skipItemWithoutPenalty,
            onSpeakingContinue: onSpeakingContinue,
          ),
        ),
      ),
    );
  }
}

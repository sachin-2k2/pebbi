import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/exercise.dart';
import 'answer_option_list.dart';
import 'audio_play_button.dart';
import 'phrase_text.dart';

/// Middle body layout for "What does this mean?" exercises.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// responsive column (or side-by-side on short landscape windows).
class ChooseMeaningBody extends StatelessWidget {
  const ChooseMeaningBody({
    super.key,
    required this.exercise,
    required this.selectedOptionId,
    required this.removedOptionIds,
    required this.isLocked,
    required this.isPlayingAudio,
    required this.showHelperLine,
    required this.onOptionSelected,
    required this.onPlayAudio,
  });

  final ChooseMeaningExercise exercise;
  final String? selectedOptionId;
  final Set<String> removedOptionIds;
  final bool isLocked;
  final bool isPlayingAudio;
  final bool showHelperLine;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onPlayAudio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            exercise.prompt,
            textAlign: TextAlign.center,
            style: AppTypography.screenTitle.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AudioPlayButton(onPressed: onPlayAudio, isPlaying: isPlayingAudio),
          const SizedBox(height: AppSpacing.md),
          PhraseText(
            phrase: exercise.phrase,
            locale: exercise.audioLocale,
            helperLine: exercise.helperLine,
            showHelperLine: showHelperLine,
          ),
          const SizedBox(height: AppSpacing.xl),
          AnswerOptionList(
            options: exercise.options,
            selectedOptionId: selectedOptionId,
            removedOptionIds: removedOptionIds,
            isLocked: isLocked,
            onOptionSelected: onOptionSelected,
          ),
        ],
      ),
    );
  }
}

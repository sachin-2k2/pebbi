import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';
import '../../../../domain/exercise.dart';
import 'level_dots.dart';
import 'mic_button.dart';
import 'speak_phrase_card.dart';
import 'speak_tip_note.dart';

/// Screen A: Microphone ready state for the "Say it out loud" exercise.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// responsive column layout without fixed heights.
class SpeakBody extends StatelessWidget {
  const SpeakBody({
    super.key,
    required this.exercise,
    required this.isListening,
    required this.soundLevel,
    required this.onMicTap,
    required this.onHearIt,
    required this.onRatherNotSpeak,
  });

  final SpeakExercise exercise;
  final bool isListening;
  final double soundLevel;
  final VoidCallback onMicTap;
  final VoidCallback onHearIt;
  final VoidCallback onRatherNotSpeak;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          SpeakPhraseCard(
            phrase: exercise.phrase,
            meaning: exercise.meaning,
            helperLine: exercise.helperLine,
            onHearIt: onHearIt,
          ),
          const SizedBox(height: AppSpacing.xl),
          LevelDots(soundLevel: soundLevel, isListening: isListening),
          const SizedBox(height: AppSpacing.md),
          MicButton(
            onPressed: onMicTap,
            isListening: isListening,
            isEnabled: true,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.speakTapMicPrompt,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          _RatherNotLink(onTap: onRatherNotSpeak),
          const SizedBox(height: AppSpacing.xl),
          const SpeakTipNote(),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _RatherNotLink extends StatelessWidget {
  const _RatherNotLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final linkColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    return Semantics(
      button: true,
      label: AppStrings.speakRatherNotActionSemantics,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            AppStrings.speakRatherNotAction,
            style: AppTypography.caption.copyWith(
              color: linkColor,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: linkColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

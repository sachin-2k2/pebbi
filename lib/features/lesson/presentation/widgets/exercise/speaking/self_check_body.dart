import 'package:flutter/material.dart';
import '../../../../../../core/design_system/pebbi_mascot.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';
import '../../../../domain/exercise.dart';
import '../../../../domain/self_check_reason.dart';
import 'self_check_actions.dart';
import 'self_check_card.dart';
import 'speak_tip_note.dart';

/// Screen B: Self-check fallback state for speaking exercises.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// displays friendly mascot, zero-shame supportive subtitle, and half-credit options.
class SelfCheckBody extends StatelessWidget {
  const SelfCheckBody({
    super.key,
    required this.exercise,
    this.reason,
    required this.onHearAgain,
    required this.onSaidIt,
    required this.onSkip,
  });

  final SpeakExercise exercise;
  final SelfCheckReason? reason;
  final VoidCallback onHearAgain;
  final VoidCallback onSaidIt;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitle = AppStrings.selfCheckSubtitleFor(reason);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xs),
          const PebbiMascot(
            size: 76.0,
            expression: PebbiExpression.happy,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.selfCheckTitle,
            style: AppTypography.cardTitle.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          SelfCheckCard(
            phrase: exercise.phrase,
            meaning: exercise.meaning,
            helperLine: exercise.helperLine,
            onHearAgain: onHearAgain,
          ),
          const SizedBox(height: AppSpacing.lg),
          SelfCheckActions(
            onSaidIt: onSaidIt,
            onSkip: onSkip,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SpeakTipNote(),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/design_system/benefit_chip.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/level_info.dart';

/// Centered row of three tinted status chips: current level, first-try score,
/// and saved streak.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// wraps gracefully on narrow viewports or large text scale.
class ResultChipRow extends StatelessWidget {
  const ResultChipRow({
    super.key,
    required this.levelInfo,
    required this.firstTryCorrect,
    required this.totalQuestions,
    this.streakDay,
    this.isScoreVisible = true,
  });

  final LevelInfo levelInfo;
  final int firstTryCorrect;
  final int totalQuestions;
  final int? streakDay;
  final bool isScoreVisible;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        BenefitChip(
          label: levelInfo.name,
          tone: ChipTone.purple,
          showDefaultIcon: false,
          leading: ExcludeSemantics(
            child: Text(
              levelInfo.emoji,
              style: const TextStyle(fontSize: 13.0),
            ),
          ),
        ),
        if (isScoreVisible)
          BenefitChip(
            label: AppStrings.placementFirstTryScore(
              firstTryCorrect,
              totalQuestions,
            ),
            tone: ChipTone.amber,
            showDefaultIcon: false,
          ),
        if (streakDay != null && streakDay! > 0)
          BenefitChip(
            label: AppStrings.placementDayStreakSaved(streakDay!),
            tone: ChipTone.mint,
            showDefaultIcon: false,
          ),
      ],
    );
  }
}

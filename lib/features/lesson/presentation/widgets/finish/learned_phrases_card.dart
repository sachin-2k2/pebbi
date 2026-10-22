import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/completion_config.dart';
import '../../../domain/lesson_completion.dart';
import 'learned_phrase_row.dart';
import 'more_learned_line.dart';

/// Card container displaying phrases introduced or practiced in this lesson.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines.
/// Hides completely if [phrases] is empty.
class LearnedPhrasesCard extends StatelessWidget {
  const LearnedPhrasesCard({
    super.key,
    required this.phrases,
    this.onPlayPhrase,
    this.showHelperLine = false,
  });

  final List<LearnedPhrase> phrases;
  final ValueChanged<LearnedPhrase>? onPlayPhrase;
  final bool showHelperLine;

  @override
  Widget build(BuildContext context) {
    if (phrases.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    final visiblePhrases = phrases
        .take(CompletionConfig.maxLearnedPhrasesDisplayed)
        .toList();
    final extraCount = phrases.length - visiblePhrases.length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border, width: 1.0),
        boxShadow: isDark ? null : AppSpacing.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.youCanNowSayTitle,
            style: AppTypography.cardTitle.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16.0,
              color: titleColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (int i = 0; i < visiblePhrases.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.xs + 2.0),
            LearnedPhraseRow(
              phrase: visiblePhrases[i],
              showHelperLine: showHelperLine,
              onTap: () => onPlayPhrase?.call(visiblePhrases[i]),
            ),
          ],
          if (extraCount > 0) MoreLearnedLine(extraCount: extraCount),
        ],
      ),
    );
  }
}

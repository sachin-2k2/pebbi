import 'package:flutter/material.dart';
import '../../../../../core/design_system/pebbi_mascot.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../providers/exercise_session_state.dart';

/// Top row of the feedback panel displaying Pebbi mascot and status title.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// happy mascot for correct, sad mascot for wrong, WCAG AAA text colors.
class FeedbackHeader extends StatelessWidget {
  const FeedbackHeader({super.key, required this.kind});

  final FeedbackKind kind;

  @override
  Widget build(BuildContext context) {
    final isCorrect = kind == FeedbackKind.correct;
    final mascotExpression = isCorrect
        ? PebbiExpression.happy
        : PebbiExpression.sad;
    final title = isCorrect
        ? AppStrings.feedbackCorrectTitle
        : AppStrings.feedbackWrongTitle;
    final titleColor = isCorrect
        ? AppColors.successTextHeader
        : AppColors.errorTextHeader;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PebbiMascot(size: 46.0, expression: mascotExpression),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            title,
            style: AppTypography.cardTitle.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
        ),
      ],
    );
  }
}

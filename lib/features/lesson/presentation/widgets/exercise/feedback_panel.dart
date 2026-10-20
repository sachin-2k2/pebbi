import 'package:flutter/material.dart';
import '../../../../../core/layout/content_width_limiter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/exercise.dart';
import '../../providers/exercise_session_state.dart';
import 'feedback_actions.dart';
import 'feedback_header.dart';

/// Animated sliding feedback panel presented after pressing "Check".
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// accessible live region announcement, handles correct & wrong variants.
class FeedbackPanel extends StatelessWidget {
  const FeedbackPanel({
    super.key,
    required this.kind,
    required this.exercise,
    required this.onContinue,
    required this.onWhy,
  });

  final FeedbackKind kind;
  final Exercise exercise;
  final VoidCallback onContinue;
  final VoidCallback onWhy;

  @override
  Widget build(BuildContext context) {
    final isCorrect = kind == FeedbackKind.correct;
    final bg = isCorrect ? AppColors.successSurface : AppColors.errorSurface;
    final border = isCorrect ? AppColors.successBorder : AppColors.errorBorder;

    final announcement = isCorrect
        ? 'Correct. ${AppStrings.feedbackCorrectTitle}'
        : 'Not quite. ${AppStrings.feedbackCorrectAnswer(exercise.correctAnswerText)}';

    return Semantics(
      liveRegion: true,
      label: announcement,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border(top: BorderSide(color: border, width: 1.5)),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusCard),
          ),
        ),
        child: SafeArea(
          top: false,
          child: ContentWidthLimiter(
            maxWidth: AppSpacing.maxContentWidthCompact,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDragHandle(),
                const SizedBox(height: AppSpacing.sm),
                FeedbackHeader(kind: kind),
                const SizedBox(height: AppSpacing.sm),
                _buildBodyContent(isCorrect),
                const SizedBox(height: AppSpacing.lg),
                FeedbackActions(
                  kind: kind,
                  onContinue: onContinue,
                  onWhy: onWhy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 36.0,
        height: 4.0,
        decoration: BoxDecoration(
          color: const Color(0xFFD4CFE2),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
      ),
    );
  }

  Widget _buildBodyContent(bool isCorrect) {
    if (isCorrect) {
      return Text(
        exercise.feedbackSuccessText,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.feedbackCorrectAnswer(exercise.correctAnswerText),
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          AppStrings.feedbackRedoNotice,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

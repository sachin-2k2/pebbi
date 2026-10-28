import 'package:flutter/material.dart';
import 'package:peddi/core/design_system/button_3d.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/core/theme/app_spacing.dart';
import 'package:peddi/core/theme/app_typography.dart';
import 'package:peddi/features/onboarding/domain/placement_question.dart';

/// Feedback panel revealed upon selecting an option.
///
/// Follows AGENTS.md §3: under 150 lines, stateful for local "Why?" toggle,
/// handles submission progress and retry states.
class PlacementFeedbackPanel extends StatefulWidget {
  const PlacementFeedbackPanel({
    super.key,
    required this.selectedOption,
    this.question,
    required this.isLastQuestion,
    required this.isSubmitting,
    this.submitError,
    required this.onContinue,
    required this.onRetry,
  });

  final PlacementOption selectedOption;
  final PlacementQuestion? question;
  final bool isLastQuestion;
  final bool isSubmitting;
  final String? submitError;
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  @override
  State<PlacementFeedbackPanel> createState() => _PlacementFeedbackPanelState();
}

class _PlacementFeedbackPanelState extends State<PlacementFeedbackPanel> {
  bool _showWhy = false;

  @override
  Widget build(BuildContext context) {
    final option = widget.selectedOption;
    final isCorrect = option.isCorrect;
    var message = isCorrect ? option.pebbiCorrect : option.pebbiWrong;
    if (message.trim().isEmpty && widget.question != null) {
      message = (isCorrect
              ? widget.question!.pebbiCorrect
              : widget.question!.pebbiWrong) ??
          '';
    }
    if (message.trim().isEmpty) {
      message = isCorrect ? 'Spot on! ⭐' : 'Not quite! Keep going 💪';
    }

    final funFact = (option.funFact != null && option.funFact!.trim().isNotEmpty)
        ? option.funFact
        : widget.question?.funFact;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.mint.withValues(alpha: 0.12)
            : AppColors.coral.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
        border: Border(
          top: BorderSide(
            color: isCorrect ? AppColors.mint : AppColors.coral,
            width: 2.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                  color: isCorrect ? AppColors.mint : AppColors.coral,
                  size: 28.0,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    message,
                    style: AppTypography.cardTitle.copyWith(
                      color: isCorrect
                          ? AppColors.mintDepth
                          : AppColors.coralDepth,
                    ),
                  ),
                ),
              ],
            ),
            if (funFact != null && funFact.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                key: const Key('placement_why_button'),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48.0, 36.0),
                ),
                onPressed: () => setState(() => _showWhy = !_showWhy),
                child: Text(
                  _showWhy ? 'Hide explanation' : 'Why this answer?',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.brandPurple,
                  ),
                ),
              ),
              if (_showWhy)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    funFact,
                    key: const Key('placement_fun_fact_text'),
                    style: AppTypography.bodyMedium,
                  ),
                ),
            ],
            if (widget.submitError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.submitError!,
                style: AppTypography.caption.copyWith(color: AppColors.coral),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (widget.isSubmitting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (widget.submitError != null)
              Button3D(
                key: const Key('placement_retry_submit_button'),
                label: 'Retry',
                backgroundColor: AppColors.brandPurple,
                onPressed: widget.onRetry,
              )
            else
              Button3D(
                key: const Key('placement_continue_button'),
                label: widget.isLastQuestion ? 'See Results' : 'Continue',
                backgroundColor: isCorrect
                    ? AppColors.mint
                    : AppColors.brandPurple,
                onPressed: widget.onContinue,
              ),
          ],
        ),
      ),
    );
  }
}

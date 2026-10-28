import 'package:flutter/material.dart';
import 'package:peddi/core/theme/app_spacing.dart';
import 'package:peddi/core/theme/app_typography.dart';

/// Top bar for placement quiz displaying progress and an exit button.
///
/// Follows AGENTS.md §3: single-purpose widget under 100 lines.
class PlacementQuizHeader extends StatelessWidget {
  const PlacementQuizHeader({
    super.key,
    required this.currentQuestionNumber,
    required this.totalQuestions,
    required this.onBack,
  });

  final int currentQuestionNumber;
  final int totalQuestions;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Exit placement quiz',
            onPressed: onBack,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Question $currentQuestionNumber of $totalQuestions',
              style: AppTypography.labelMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48.0), // Balance close button spacing
        ],
      ),
    );
  }
}

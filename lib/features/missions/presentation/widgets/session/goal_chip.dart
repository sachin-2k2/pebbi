import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/session_goal.dart';

/// Single goal chip in the session goals strip.
///
/// Follows AGENTS.md §3 & §8:
/// - Empty circle when pending, animated mint circle with check icon when done
/// - TODO(question: goal done look is estimated based on mint palette token)
class GoalChip extends StatelessWidget {
  const GoalChip({
    super.key,
    required this.goal,
    required this.index,
    required this.total,
  });

  final SessionGoal goal;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDone = goal.isDone;

    final circle = isDone
        ? Container(
            width: 14.0,
            height: 14.0,
            decoration: BoxDecoration(
              color: palette.mint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_rounded,
              size: 10.0,
              color: Colors.white,
            ),
          )
        : Container(
            width: 14.0,
            height: 14.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: palette.textMuted, width: 1.4),
            ),
          );

    return Semantics(
      container: true,
      label: AppStrings.sessionGoalChipSemantics(
        index,
        total,
        goal.text,
        isDone,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2.0,
        ),
        decoration: BoxDecoration(
          color: palette.isDark ? palette.surfaceVariant : palette.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: isDone ? palette.mint : palette.outline,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            circle,
            const SizedBox(width: AppSpacing.xs + 2.0),
            Flexible(
              child: Text(
                goal.text,
                style: AppTypography.caption.copyWith(
                  color: palette.textPrimary,
                  fontWeight: isDone ? FontWeight.w700 : FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

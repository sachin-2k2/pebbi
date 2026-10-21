import 'package:flutter/material.dart';
import '../../../../core/design_system/ring.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_strings.dart';

/// Circular progress ring for the daily goal card.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §8.
class GoalRing extends StatelessWidget {
  const GoalRing({
    super.key,
    required this.progress,
    required this.isDone,
    required this.doneCount,
    required this.targetCount,
    this.size = 62.0,
  });

  final double progress;
  final bool isDone;
  final int doneCount;
  final int targetCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.tintLavender.withValues(alpha: 0.8);
    final ringColor = isDone ? AppColors.accentMint : AppColors.brandPurple;
    final circleBorderColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    Widget childWidget;
    if (isDone) {
      childWidget = const Icon(
        Icons.check_rounded,
        color: AppColors.accentMint,
        size: 26.0,
      );
    } else {
      childWidget = Container(
        width: 14.0,
        height: 14.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: circleBorderColor, width: 1.6),
        ),
      );
    }

    return Ring(
      progress: isDone ? 1.0 : progress,
      size: size,
      strokeWidth: 6.0,
      color: ringColor,
      trackColor: trackColor,
      semanticsLabel: AppStrings.rewardsGoalSemantics(doneCount, targetCount),
      child: childWidget,
    );
  }
}

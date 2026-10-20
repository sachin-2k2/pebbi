import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Title block widget for onboarding setup steps:
/// small purple Pebbi mascot + bold title + muted subtitle.
///
/// Follows AGENTS.md §3 and §4: under 100 lines, build under 50 lines,
/// handles text scaling and responsiveness.
class StepTitleBlock extends StatelessWidget {
  const StepTitleBlock({
    super.key,
    required this.title,
    required this.subtitle,
    this.showMascot = true,
    this.mascotSize = 48.0,
    this.mascotOutfit = PebbiOutfit.defaultPurple,
    this.mascotExpression = PebbiExpression.happy,
  });

  final String title;
  final String subtitle;
  final bool showMascot;
  final double mascotSize;
  final PebbiOutfit mascotOutfit;
  final PebbiExpression mascotExpression;

  @override
  Widget build(BuildContext context) {
    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.screenTitle.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: showMascot
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PebbiMascot(
                  size: mascotSize,
                  outfit: mascotOutfit,
                  expression: mascotExpression,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: textColumn),
              ],
            )
          : textColumn,
    );
  }
}

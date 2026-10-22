import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';

/// Centered title and updated progress line for Match the Pairs.
///
/// Follows AGENTS.md §3 & §4: under 60 lines.
class MatchProgressText extends StatelessWidget {
  const MatchProgressText({
    super.key,
    required this.matchedCount,
    required this.totalPairs,
  });

  final int matchedCount;
  final int totalPairs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          AppStrings.matchPairsTitle,
          style: AppTypography.screenTitle.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.matchPairsProgress(matchedCount, totalPairs),
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

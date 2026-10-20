import 'package:flutter/material.dart';
import '../../../../../core/design_system/pebbi_mascot.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Hero section of the placement result screen displaying surprised Pebbi,
/// level title, and encouraging subtitle.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// clamped mascot scaling on short heights, header semantics for title.
class ResultHero extends StatelessWidget {
  const ResultHero({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mascotSize = (screenHeight * 0.12).clamp(64.0, 104.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: PebbiMascot(
            size: mascotSize,
            expression: PebbiExpression.surprised,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.screenTitle.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppStrings.placementResultSubtitle,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

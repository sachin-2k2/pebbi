import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/lesson_result.dart';

/// Temporary placeholder screen presenting raw [LessonResult] after lesson completion.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines.
/// TODO(question): Full finish screen with stars, outfits, and streak to be designed.
class LessonFinishPlaceholderScreen extends StatelessWidget {
  const LessonFinishPlaceholderScreen({
    super.key,
    this.result,
    this.stopId = '1',
  });

  final LessonResult? result;
  final String stopId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ContentWidthLimiter(
          maxWidth: AppSpacing.maxContentWidthCompact,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                AppStrings.lessonFinishPlaceholderTitle,
                style: AppTypography.display.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Stop $stopId • Score: ${result?.firstTryPercentage ?? 100}%',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1.0,
                    ),
                  ),
                  child: ListView(
                    children: [
                      Text(
                        'Total items: ${result?.totalItems ?? 12}',
                        style: AppTypography.bodyMedium,
                      ),
                      Text(
                        'First-try correct: ${result?.firstTryCorrectCount ?? 0}',
                        style: AppTypography.bodyMedium,
                      ),
                      Text(
                        'Mistakes: ${result?.totalMistakes ?? 0}',
                        style: AppTypography.bodyMedium,
                      ),
                      const Divider(height: AppSpacing.lg),
                      if (result != null)
                        for (final entry in result!.itemRecords.entries)
                          Text(
                            '${entry.key}: attempts=${entry.value.attempts}, correct=${entry.value.firstTryCorrect}, skipped=${entry.value.skipped}',
                            style: AppTypography.caption,
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Button3D(
                label: 'Back to Path',
                backgroundColor: AppColors.mint,
                depthColor: AppColors.mintDepth,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

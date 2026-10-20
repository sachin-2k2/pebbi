import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Placeholder screen for lesson routes (e.g. `/lesson/1`).
///
/// TODO(question): Full interactive lesson curriculum, exercise host, and guest sign-in
/// prompt when starting the first lesson will be built in the lesson feature milestone.
class LessonPlaceholderScreen extends StatelessWidget {
  const LessonPlaceholderScreen({super.key, this.lessonNumber = 1});

  final int lessonNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => context.go('/path'),
        ),
      ),
      body: SafeArea(
        child: ContentWidthLimiter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 64,
                  color: AppColors.brandPurple,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Lesson $lessonNumber',
                  style: AppTypography.screenTitle.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppStrings.lessonPlaceholderSubtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Button3D(
                  label: 'Go to Path',
                  backgroundColor: AppColors.brandPurple,
                  depthColor: AppColors.brandPurpleDepth,
                  onPressed: () => context.go('/path'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

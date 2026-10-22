import 'package:flutter/material.dart';
import '../../../../core/design_system/back_link.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Placeholder screen for Help and fixes settings.
///
/// TODO(question: support contact, diagnostic exports, and FAQ content needed).
class HelpPlaceholderScreen extends StatelessWidget {
  const HelpPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ContentWidthLimiter(
          maxWidth: AppSpacing.maxContentWidthCompact,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackLink(label: AppStrings.settingsMoreTitle),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.settingsHelpPlaceholderTitle,
                style: AppTypography.screenTitle.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.settingsHelpPlaceholderSubtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Placeholder screen for `/premium/options`.
///
/// TODO(question): Full subscription options screen/sheet design pending from design team.
/// Must include Apple/Google compliance terms: recurring pricing, trial duration,
/// cancellation policies, and links to Terms of Service & Privacy Policy.
class PremiumOptionsPlaceholderScreen extends StatelessWidget {
  const PremiumOptionsPlaceholderScreen({super.key});

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
          onPressed: () => _handleReturn(context),
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
                  Icons.workspace_premium,
                  size: 64,
                  color: AppColors.brandPurple,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppStrings.premiumOptionsPlaceholderTitle,
                  style: AppTypography.screenTitle.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppStrings.premiumOptionsPlaceholderSubtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Button3D(
                  label: AppStrings.backToOfferAction,
                  backgroundColor: AppColors.brandPurple,
                  depthColor: AppColors.brandPurpleDepth,
                  onPressed: () => _handleReturn(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleReturn(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/onboarding/setup/step-10');
    }
  }
}

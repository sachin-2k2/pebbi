import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/layout/content_width_limiter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';

/// Pinned bottom bar container housing the Mint 3D Continue action.
///
/// Follows AGENTS.md §3 & §4: under 60 lines, build under 35 lines.
class CompletionBottomBar extends StatelessWidget {
  const CompletionBottomBar({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: ContentWidthLimiter(
        maxWidth: AppSpacing.maxContentWidthCompact,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Button3D(
            label: AppStrings.continueButton,
            backgroundColor: AppColors.mint,
            depthColor: AppColors.mintDepth,
            onPressed: onContinue,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Full-width outlined social authentication button.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, 48dp minimum tap target.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.googleSignInSemantics,
      child: SizedBox(
        width: double.infinity,
        height: 52.0,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.borderLight, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                googleIconAsset,
                width: 22.0,
                height: 22.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: AppSpacing.sm + 2.0),
              Flexible(
                child: Text(
                  AppStrings.continueWithGoogle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Asset path to the Google logo image.
  static const String googleIconAsset = 'assets/images/google.png';
}

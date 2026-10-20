import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Resend action button supporting cooldown countdown state and accessible touch targets.
///
/// Follows AGENTS.md §3 & §4: under 80 lines, 48dp touch target, scalable typography.
class ResendButton extends StatelessWidget {
  const ResendButton({
    super.key,
    required this.canResend,
    required this.cooldownSeconds,
    required this.onPressed,
    this.isLoading = false,
  });

  final bool canResend;
  final int cooldownSeconds;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final label = canResend
        ? AppStrings.resendLinkAction
        : AppStrings.resendCooldownAction(cooldownSeconds);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48.0),
      child: Center(
        child: TextButton(
          onPressed: (canResend && !isLoading) ? onPressed : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.brandPurple,
                    ),
                  ),
                )
              : Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: canResend
                        ? AppColors.linkPurple
                        : AppColors.disabledText,
                    fontWeight: canResend ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}

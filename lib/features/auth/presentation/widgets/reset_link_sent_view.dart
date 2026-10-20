import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import 'resend_button.dart';

/// Confirmation view displayed inside the card after a reset link has been requested.
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 50 lines, neutral copy.
class ResetLinkSentView extends StatelessWidget {
  const ResetLinkSentView({
    super.key,
    required this.email,
    required this.canResend,
    required this.cooldownSeconds,
    required this.onResend,
    this.isResending = false,
  });

  final String email;
  final bool canResend;
  final int cooldownSeconds;
  final VoidCallback onResend;
  final bool isResending;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _EnvelopeIcon(),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Text(
            AppStrings.checkYourInboxTitle,
            textAlign: TextAlign.center,
            style: AppTypography.screenTitle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.resetLinkSentNeutralMessage(email),
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textMuted,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ResendButton(
          canResend: canResend,
          cooldownSeconds: cooldownSeconds,
          onPressed: onResend,
          isLoading: isResending,
        ),
      ],
    );
  }
}

class _EnvelopeIcon extends StatelessWidget {
  const _EnvelopeIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 64.0,
        height: 64.0,
        decoration: const BoxDecoration(
          color: AppColors.tintLavender,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.mail_outline_rounded,
            size: 32.0,
            color: AppColors.brandPurple,
          ),
        ),
      ),
    );
  }
}

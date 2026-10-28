import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/verify_otp_form_provider.dart';
import 'auth_card.dart';
import 'auth_header.dart';
import 'auth_text_link.dart';
import 'general_error_banner.dart';
import 'otp_input_field.dart';
import 'resend_button.dart';

/// Presentation body for the OTP verification screen.
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 50 lines.
class VerifyOtpBody extends StatelessWidget {
  const VerifyOtpBody({
    super.key,
    required this.email,
    required this.formState,
    required this.otpController,
    required this.otpFocusNode,
    required this.onOtpChanged,
    required this.onVerify,
    required this.onResend,
    required this.onChangeEmail,
  });

  final String email;
  final VerifyOtpFormState formState;
  final TextEditingController otpController;
  final FocusNode otpFocusNode;
  final ValueChanged<String> onOtpChanged;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onChangeEmail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeader(
            title: 'Check your email',
            subtitle: 'We sent a 6-digit verification code to\n$email',
            badgeIcon: Icons.mark_email_read_rounded,
          ),
          Transform.translate(
            offset: const Offset(0, -AppSpacing.xl * 1.5),
            child: ContentWidthLimiter(
              maxWidth: 480.0,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (formState.generalError != null) ...[
                          GeneralErrorBanner(message: formState.generalError!),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if (formState.resendMessage != null) ...[
                          _buildResendSuccessBanner(formState.resendMessage!),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        OtpInputField(
                          controller: otpController,
                          focusNode: otpFocusNode,
                          enabled: !formState.isSubmitting,
                          onChanged: onOtpChanged,
                          onSubmitted: (_) => onVerify(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Button3D(
                          label: formState.isSubmitting
                              ? 'Verifying...'
                              : 'Verify & Create Account',
                          icon: formState.isSubmitting
                              ? const SizedBox(
                                  width: 18.0,
                                  height: 18.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : null,
                          backgroundColor: formState.isSubmitting
                              ? AppColors.disabled
                              : AppColors.mint,
                          depthColor: formState.isSubmitting
                              ? AppColors.disabledDepth
                              : AppColors.mintDepth,
                          textColor: Colors.white,
                          isFullWidth: true,
                          onPressed:
                              formState.isSubmitting ? null : onVerify,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ResendButton(
                          canResend: formState.canResend,
                          cooldownSeconds: formState.cooldownRemainingSeconds,
                          isLoading: formState.isResending,
                          onPressed: onResend,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AuthTextLink(
                    actionText: 'Wrong email? Change email',
                    leadingIcon: Icons.arrow_back_rounded,
                    actionStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.linkPurple,
                    ),
                    onTap: onChangeEmail,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResendSuccessBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.mint.withAlpha(25),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.mint.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(
                color: AppColors.mintDepth,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

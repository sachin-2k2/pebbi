import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import 'email_field.dart';
import 'general_error_banner.dart';

/// Form content for the Forgot Password card before submission.
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 50 lines, WCAG AA contrast.
class ForgotPasswordForm extends StatelessWidget {
  const ForgotPasswordForm({
    super.key,
    required this.emailController,
    required this.emailFocusNode,
    required this.isSubmitting,
    required this.onSubmit,
    this.emailError,
    this.generalError,
  });

  final TextEditingController emailController;
  final FocusNode emailFocusNode;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final String? emailError;
  final String? generalError;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (generalError != null && generalError!.isNotEmpty) ...[
            GeneralErrorBanner(message: generalError!),
            const SizedBox(height: AppSpacing.md),
          ],
          EmailField(
            controller: emailController,
            focusNode: emailFocusNode,
            label: AppStrings.emailAddressLabel,
            labelStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.normal,
            ),
            errorMessage: emailError,
            enabled: !isSubmitting,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SubmitButton(isSubmitting: isSubmitting, onSubmit: onSubmit),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isSubmitting, required this.onSubmit});

  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Button3D(
      label: isSubmitting
          ? AppStrings.sendingResetLinkProcessing
          : AppStrings.sendResetLinkAction,
      icon: isSubmitting
          ? const SizedBox(
              width: 18.0,
              height: 18.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : null,
      backgroundColor: isSubmitting ? AppColors.disabled : AppColors.mint,
      depthColor: isSubmitting ? AppColors.disabledDepth : AppColors.mintDepth,
      textColor: Colors.white,
      isFullWidth: true,
      onPressed: isSubmitting ? null : onSubmit,
    );
  }
}

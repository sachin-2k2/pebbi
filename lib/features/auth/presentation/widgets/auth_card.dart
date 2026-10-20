import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import 'confirm_password_field.dart';
import 'email_field.dart';
import 'general_error_banner.dart';
import 'or_divider.dart';
import 'password_field.dart';
import 'social_button.dart';

/// White overlapping card for auth forms or custom auth content.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines.
class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    this.child,
    this.emailController,
    this.passwordController,
    this.isPasswordObscured = false,
    this.isSubmitting = false,
    this.onTogglePasswordVisibility,
    this.onGoogleSignIn,
    this.onLogin,
    this.onSubmit,
    this.submitLabel = AppStrings.logInAction,
    this.submittingLabel = AppStrings.loggingInProcessing,
    this.onForgotPassword,
    this.emailFocusNode,
    this.passwordFocusNode,
    this.emailError,
    this.passwordError,
    this.generalError,
    this.confirmPasswordController,
    this.confirmPasswordFocusNode,
    this.isConfirmPasswordObscured = true,
    this.confirmPasswordError,
    this.onToggleConfirmPasswordVisibility,
    this.termsPlaceholder,
  });

  final Widget? child;
  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final bool isPasswordObscured;
  final bool isSubmitting;
  final VoidCallback? onTogglePasswordVisibility;
  final VoidCallback? onGoogleSignIn;
  final VoidCallback? onLogin;
  final VoidCallback? onSubmit;
  final String submitLabel;
  final String submittingLabel;
  final VoidCallback? onForgotPassword;
  final FocusNode? emailFocusNode;
  final FocusNode? passwordFocusNode;
  final String? emailError;
  final String? passwordError;
  final String? generalError;
  final TextEditingController? confirmPasswordController;
  final FocusNode? confirmPasswordFocusNode;
  final bool isConfirmPasswordObscured;
  final String? confirmPasswordError;
  final VoidCallback? onToggleConfirmPasswordVisibility;
  final Widget? termsPlaceholder;

  VoidCallback get _effectiveSubmit => onSubmit ?? onLogin ?? () {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x181E1647),
            blurRadius: 24.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child ?? _buildDefaultForm(),
    );
  }

  Widget _buildDefaultForm() {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onGoogleSignIn != null) ...[
            SocialButton(onPressed: onGoogleSignIn!, isLoading: isSubmitting),
            const SizedBox(height: AppSpacing.md),
            const OrDivider(),
            const SizedBox(height: AppSpacing.md),
          ],
          if (generalError != null && generalError!.isNotEmpty) ...[
            GeneralErrorBanner(message: generalError!),
            const SizedBox(height: AppSpacing.md),
          ],
          if (emailController != null)
            EmailField(
              controller: emailController!,
              focusNode: emailFocusNode,
              errorMessage: emailError,
              enabled: !isSubmitting,
              onFieldSubmitted: (_) => passwordFocusNode?.requestFocus(),
            ),
          if (passwordController != null) ...[
            const SizedBox(height: AppSpacing.md),
            PasswordField(
              controller: passwordController!,
              focusNode: passwordFocusNode,
              isObscured: isPasswordObscured,
              errorMessage: passwordError,
              enabled: !isSubmitting,
              isNewPassword: confirmPasswordController != null,
              textInputAction: confirmPasswordController != null
                  ? TextInputAction.next
                  : TextInputAction.done,
              onToggleVisibility: onTogglePasswordVisibility ?? () {},
              onForgotPassword: onForgotPassword,
              onFieldSubmitted: (_) {
                if (confirmPasswordFocusNode != null) {
                  confirmPasswordFocusNode!.requestFocus();
                } else {
                  _effectiveSubmit();
                }
              },
            ),
          ],
          if (confirmPasswordController != null) ...[
            const SizedBox(height: AppSpacing.md),
            ConfirmPasswordField(
              controller: confirmPasswordController!,
              focusNode: confirmPasswordFocusNode,
              isObscured: isConfirmPasswordObscured,
              errorMessage: confirmPasswordError,
              enabled: !isSubmitting,
              onToggleVisibility: onToggleConfirmPasswordVisibility ?? () {},
              onFieldSubmitted: (_) => _effectiveSubmit(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _buildSubmitButton(),
          if (termsPlaceholder != null) ...[
            const SizedBox(height: AppSpacing.md),
            termsPlaceholder!,
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Button3D(
      label: isSubmitting ? submittingLabel : submitLabel,
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
      onPressed: isSubmitting ? null : _effectiveSubmit,
    );
  }
}

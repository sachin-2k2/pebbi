import 'package:flutter/material.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../providers/register_form_provider.dart';
import 'auth_card.dart';
import 'auth_header.dart';
import 'auth_switch_link.dart';

/// Scrollable body for the register screen composing header, card, and switch link.
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 50 lines.
class RegisterBody extends StatelessWidget {
  const RegisterBody({
    super.key,
    required this.formState,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.onRegister,
    required this.onGoogleSignIn,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.onLogin,
  });

  final RegisterFormState formState;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final VoidCallback onRegister;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: AppStrings.createAccountTitle,
            subtitle: AppStrings.createAccountSubtitle,
            badgeIcon: Icons.person_add_rounded,
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
                    emailController: emailController,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                    emailFocusNode: emailFocusNode,
                    passwordFocusNode: passwordFocusNode,
                    confirmPasswordFocusNode: confirmPasswordFocusNode,
                    isPasswordObscured: formState.isPasswordObscured,
                    isConfirmPasswordObscured:
                        formState.isConfirmPasswordObscured,
                    isSubmitting: formState.isSubmitting,
                    emailError: formState.emailError,
                    passwordError: formState.passwordError,
                    confirmPasswordError: formState.confirmPasswordError,
                    generalError: formState.generalError,
                    submitLabel: AppStrings.createAccountAction,
                    submittingLabel: AppStrings.creatingAccountProcessing,
                    onTogglePasswordVisibility: onTogglePasswordVisibility,
                    onToggleConfirmPasswordVisibility:
                        onToggleConfirmPasswordVisibility,
                    onSubmit: onRegister,
                    onGoogleSignIn: onGoogleSignIn,
                    termsPlaceholder: const _TermsPlaceholder(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AuthSwitchLink(
                    promptText: AppStrings.alreadyHaveAnAccount,
                    actionText: AppStrings.logInAction,
                    onTap: onLogin,
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
}

/// Placeholder slot for legal terms & privacy policy consent.
///
/// TODO(question): What exact legal/terms wording and consent mechanisms (e.g. checkbox)
/// are required for GDPR, COPPA, and app store compliance during account registration?
class _TermsPlaceholder extends StatelessWidget {
  const _TermsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        AppStrings.termsAndPrivacyPlaceholder,
        textAlign: TextAlign.center,
        style: AppTypography.caption.copyWith(
          color: AppColors.textMuted,
          fontSize: 11.0,
          height: 1.35,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/login_form_provider.dart';
import 'auth_card.dart';
import 'auth_header.dart';
import 'auth_switch_link.dart';

/// Scrollable body for the login screen composing header, card, and switch link.
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 50 lines.
class LoginBody extends StatelessWidget {
  const LoginBody({
    super.key,
    required this.formState,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.onLogin,
    required this.onGoogleSignIn,
    required this.onTogglePasswordVisibility,
    required this.onForgotPassword,
    required this.onCreateAccount,
  });

  final LoginFormState formState;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final VoidCallback onLogin;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(),
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
                    emailFocusNode: emailFocusNode,
                    passwordFocusNode: passwordFocusNode,
                    isPasswordObscured: formState.isPasswordObscured,
                    isSubmitting: formState.isSubmitting,
                    emailError: formState.emailError,
                    passwordError: formState.passwordError,
                    generalError: formState.generalError,
                    onTogglePasswordVisibility: onTogglePasswordVisibility,
                    onLogin: onLogin,
                    onGoogleSignIn: onGoogleSignIn,
                    onForgotPassword: onForgotPassword,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AuthSwitchLink(onCreateAccount: onCreateAccount),
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

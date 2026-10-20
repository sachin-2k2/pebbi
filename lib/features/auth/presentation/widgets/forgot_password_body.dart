import 'package:flutter/material.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../providers/forgot_password_form_provider.dart';
import 'auth_card.dart';
import 'auth_header.dart';
import 'auth_text_link.dart';
import 'forgot_password_form.dart';
import 'reset_link_sent_view.dart';

/// Scrollable body for Forgot Password composing header, card, and back link.
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 50 lines.
class ForgotPasswordBody extends StatelessWidget {
  const ForgotPasswordBody({
    super.key,
    required this.formState,
    required this.emailController,
    required this.emailFocusNode,
    required this.onSubmit,
    required this.onResend,
    required this.onBackToLogIn,
  });

  final ForgotPasswordFormState formState;
  final TextEditingController emailController;
  final FocusNode emailFocusNode;
  final VoidCallback onSubmit;
  final VoidCallback onResend;
  final VoidCallback onBackToLogIn;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: AppStrings.resetPasswordTitle,
            subtitle: AppStrings.resetPasswordSubtitle,
            badgeIcon: Icons.mail_outline_rounded,
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
                    child: formState.isSent
                        ? ResetLinkSentView(
                            email: formState.sentToEmail,
                            canResend: formState.canResend,
                            cooldownSeconds: formState.cooldownRemainingSeconds,
                            onResend: onResend,
                            isResending: formState.isSubmitting,
                          )
                        : ForgotPasswordForm(
                            emailController: emailController,
                            emailFocusNode: emailFocusNode,
                            isSubmitting: formState.isSubmitting,
                            onSubmit: onSubmit,
                            emailError: formState.emailError,
                            generalError: formState.generalError,
                          ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AuthTextLink(
                    actionText: AppStrings.backToLogIn,
                    leadingIcon: Icons.arrow_back_rounded,
                    actionStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.linkPurple,
                      fontWeight: FontWeight.normal,
                    ),
                    onTap: onBackToLogIn,
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

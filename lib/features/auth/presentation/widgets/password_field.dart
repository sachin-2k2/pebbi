import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import 'labeled_text_field.dart';

/// Specialized text field for password entry with eye toggle and forgot password link.
///
/// Follows AGENTS.md §3 & §4: under 120 lines, accessible eye toggle, WCAG AA compliant link.
class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.isObscured,
    required this.onToggleVisibility,
    this.label = AppStrings.passwordLabel,
    this.hintText = AppStrings.passwordPlaceholder,
    this.isNewPassword = false,
    this.textInputAction = TextInputAction.done,
    this.toggleSemanticsPrefix,
    this.onForgotPassword,
    this.focusNode,
    this.errorMessage,
    this.enabled = true,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final bool isObscured;
  final VoidCallback onToggleVisibility;
  final String label;
  final String hintText;
  final bool isNewPassword;
  final TextInputAction textInputAction;
  final String? toggleSemanticsPrefix;
  final VoidCallback? onForgotPassword;
  final FocusNode? focusNode;
  final String? errorMessage;
  final bool enabled;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return LabeledTextField(
      label: label,
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.textMuted,
        size: 22.0,
      ),
      trailingHeader: onForgotPassword != null ? _buildForgotLink() : null,
      obscureText: isObscured,
      suffixIcon: _buildEyeToggle(),
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      autofillHints: [
        isNewPassword ? AutofillHints.newPassword : AutofillHints.password,
      ],
      errorMessage: errorMessage,
      enabled: enabled,
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  Widget _buildForgotLink() {
    return Semantics(
      button: true,
      label: AppStrings.forgotPassword,
      child: GestureDetector(
        onTap: enabled ? onForgotPassword : null,
        child: Text(
          AppStrings.forgotPassword,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.linkPurple,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildEyeToggle() {
    final String label;
    if (toggleSemanticsPrefix != null) {
      label = isObscured
          ? AppStrings.showConfirmPasswordSemantics
          : AppStrings.hideConfirmPasswordSemantics;
    } else {
      label = isObscured
          ? AppStrings.showPasswordSemantics
          : AppStrings.hidePasswordSemantics;
    }

    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        icon: Icon(
          isObscured
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textMuted,
          size: 20.0,
        ),
        onPressed: enabled ? onToggleVisibility : null,
      ),
    );
  }
}

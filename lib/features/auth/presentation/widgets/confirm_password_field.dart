import 'package:flutter/material.dart';
import '../../../../l10n/app_strings.dart';
import 'password_field.dart';

/// Specialized text field for confirming password during account registration.
///
/// Follows AGENTS.md §3 & §4: under 80 lines, thin wrapper around [PasswordField].
class ConfirmPasswordField extends StatelessWidget {
  const ConfirmPasswordField({
    super.key,
    required this.controller,
    required this.isObscured,
    required this.onToggleVisibility,
    this.focusNode,
    this.errorMessage,
    this.enabled = true,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final bool isObscured;
  final VoidCallback onToggleVisibility;
  final FocusNode? focusNode;
  final String? errorMessage;
  final bool enabled;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return PasswordField(
      label: AppStrings.confirmPasswordLabel,
      hintText: AppStrings.passwordPlaceholder,
      controller: controller,
      focusNode: focusNode,
      isObscured: isObscured,
      isNewPassword: true,
      textInputAction: TextInputAction.done,
      toggleSemanticsPrefix: 'confirm',
      errorMessage: errorMessage,
      enabled: enabled,
      onToggleVisibility: onToggleVisibility,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}

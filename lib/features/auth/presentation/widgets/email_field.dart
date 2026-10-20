import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_strings.dart';
import 'labeled_text_field.dart';

/// Specialized text field for email entry with autofill and format support.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, explicit LTR text direction for email addresses.
class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.focusNode,
    this.label = AppStrings.emailLabel,
    this.labelStyle,
    this.textInputAction = TextInputAction.next,
    this.errorMessage,
    this.enabled = true,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final TextStyle? labelStyle;
  final TextInputAction textInputAction;
  final String? errorMessage;
  final bool enabled;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return LabeledTextField(
      label: label,
      labelStyle: labelStyle,
      controller: controller,
      focusNode: focusNode,
      hintText: AppStrings.emailPlaceholder,
      prefixIcon: const Icon(
        Icons.mail_outline_rounded,
        color: AppColors.textMuted,
        size: 22.0,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      textDirection: TextDirection.ltr,
      autofillHints: const [AutofillHints.email, AutofillHints.username],
      errorMessage: errorMessage,
      enabled: enabled,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}

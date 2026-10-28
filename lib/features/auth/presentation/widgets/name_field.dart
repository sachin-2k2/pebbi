import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_strings.dart';
import 'labeled_text_field.dart';

/// Specialized text field for user name entry with autofill support.
///
/// Follows AGENTS.md §3 & §4: under 60 lines, 48dp minimum touch target.
class NameField extends StatelessWidget {
  const NameField({
    super.key,
    required this.controller,
    this.focusNode,
    this.label = AppStrings.nameLabel,
    this.hintText = AppStrings.namePlaceholder,
    this.textInputAction = TextInputAction.next,
    this.errorMessage,
    this.enabled = true,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hintText;
  final TextInputAction textInputAction;
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
        Icons.person_outline_rounded,
        color: AppColors.textMuted,
        size: 22.0,
      ),
      keyboardType: TextInputType.name,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.name],
      errorMessage: errorMessage,
      enabled: enabled,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}

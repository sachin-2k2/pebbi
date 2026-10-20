import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable labeled text input field with icon, focus outline, and live error display.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, WCAG AA contrast, accessible error live region.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.labelStyle,
    this.trailingHeader,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.textDirection,
    this.autofillHints,
    this.obscureText = false,
    this.suffixIcon,
    this.errorMessage,
    this.enabled = true,
    this.onFieldSubmitted,
  });

  final String label;
  final TextStyle? labelStyle;
  final TextEditingController controller;
  final String hintText;
  final Widget prefixIcon;
  final Widget? trailingHeader;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? errorMessage;
  final bool enabled;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeaderRow(),
        const SizedBox(height: AppSpacing.xs + 2.0),
        _buildInputContainer(hasError),
        if (hasError) _buildErrorText(),
      ],
    );
  }

  Widget _buildHeaderRow() {
    final effectiveStyle =
        labelStyle ??
        AppTypography.bodyLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        );

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: 4.0,
      children: [
        Text(label, style: effectiveStyle),
        ?trailingHeader,
      ],
    );
  }

  Widget _buildInputContainer(bool hasError) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textDirection: textDirection,
      autofillHints: autofillHints,
      autocorrect: false,
      enableSuggestions: false,
      cursorColor: AppColors.brandPurple,
      style: AppTypography.bodyLarge.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      onSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.inputPlaceholder,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? Colors.white : AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.brandPurple,
            width: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorText() {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, left: 4.0),
      child: Semantics(
        liveRegion: true,
        child: Text(
          errorMessage!,
          style: AppTypography.caption.copyWith(
            color: AppColors.errorTextHeader,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Multiline rounded text input field for typing mission role-play replies.
///
/// Follows AGENTS.md §4 & §7.3:
/// - Text direction follows target language (RTL for Arabic)
/// - Autocorrect OFF to preserve learner input
/// - Multiline up to 4 lines
class ReplyTextField extends StatelessWidget {
  const ReplyTextField({
    super.key,
    required this.controller,
    required this.targetLanguageCode,
    required this.targetLanguageName,
    required this.onChanged,
    required this.onSubmitted,
    this.isEnabled = true,
  });

  final TextEditingController controller;
  final String targetLanguageCode;
  final String targetLanguageName;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isRtl = targetLanguageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        color: palette.isDark ? palette.surfaceVariant : palette.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: palette.outline, width: 0.8),
      ),
      child: TextField(
        controller: controller,
        enabled: isEnabled,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        autocorrect: false,
        enableSuggestions: true,
        textInputAction: TextInputAction.send,
        minLines: 1,
        maxLines: 4,
        onChanged: onChanged,
        onSubmitted: (_) => onSubmitted(),
        style: AppTypography.bodyMedium.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 13.0,
          ),
          hintText: AppStrings.sessionReplyPlaceholder(targetLanguageName),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: palette.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

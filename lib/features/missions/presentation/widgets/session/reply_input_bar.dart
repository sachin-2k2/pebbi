import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'reply_text_field.dart';
import 'send_button.dart';

/// Horizontal input bar combining [ReplyTextField] with [SendButton].
///
/// Follows AGENTS.md §3 (< 100 lines, build < 50 lines) & §4.
class ReplyInputBar extends StatelessWidget {
  const ReplyInputBar({
    super.key,
    required this.controller,
    required this.targetLanguageCode,
    required this.targetLanguageName,
    required this.onChanged,
    required this.onSend,
    required this.canSend,
    this.isEnabled = true,
  });

  final TextEditingController controller;
  final String targetLanguageCode;
  final String targetLanguageName;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final bool canSend;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ReplyTextField(
              controller: controller,
              targetLanguageCode: targetLanguageCode,
              targetLanguageName: targetLanguageName,
              isEnabled: isEnabled,
              onChanged: onChanged,
              onSubmitted: canSend ? onSend : () {},
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SendButton(
            isEnabled: canSend && isEnabled,
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}

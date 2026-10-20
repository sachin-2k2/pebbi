import 'package:flutter/material.dart';
import '../../../../../../core/design_system/pebbi_mascot.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';

/// Row showing Pebbi mascot on the left and a lavender speech bubble with the prompt text.
///
/// Follows AGENTS.md §3: under 100 lines, build under 50 lines, responsive wrap.
class PromptBubble extends StatelessWidget {
  const PromptBubble({super.key, required this.promptText});

  final String promptText;

  static const Color _bubbleBg = Color(0xFFF1EDFD);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const PebbiMascot(size: 48.0, expression: PebbiExpression.winking),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: _bubbleBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              promptText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

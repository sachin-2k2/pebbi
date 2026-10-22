import 'package:flutter/material.dart';
import '../../../../../../core/design_system/pebbi_mascot.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';

/// Row presenting the happy Pebbi mascot alongside a mint speech bubble with learning tip.
///
/// Follows AGENTS.md §3 & §4: under 80 lines, responsive wrapping, WCAG AA contrast.
class PebbiTipRow extends StatelessWidget {
  const PebbiTipRow({super.key, required this.tipText});

  final String tipText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const PebbiMascot(size: 48.0, expression: PebbiExpression.happy),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8FAF3),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFC7F3E2), width: 1.0),
            ),
            child: Text(
              tipText,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0D6E4E),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

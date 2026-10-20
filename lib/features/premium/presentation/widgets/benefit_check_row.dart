import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Single check-list item row for premium benefit cards.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// wraps gracefully at 200% text scale, decorative icon excluded from semantics.
class BenefitCheckRow extends StatelessWidget {
  const BenefitCheckRow({
    super.key,
    required this.text,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
  });

  final String text;
  final Color textColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(Icons.check, size: 18.0, color: iconColor),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

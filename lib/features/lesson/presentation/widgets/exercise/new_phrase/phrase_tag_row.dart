import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';

/// Top tag row displaying the "New phrase" tag and register tag (e.g. "casual", "polite").
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines, WCAG AA contrast.
class PhraseTagRow extends StatelessWidget {
  const PhraseTagRow({
    super.key,
    required this.phraseKindTag,
    required this.registerTag,
  });

  final String phraseKindTag;
  final String registerTag;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          _buildPill(
            text: phraseKindTag,
            backgroundColor: palette.brandTint,
            textColor: palette.brandText,
          ),
          _buildPill(
            text: registerTag,
            backgroundColor: palette.surfaceVariant,
            textColor: palette.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

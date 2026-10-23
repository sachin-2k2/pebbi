import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/suggestion.dart';

/// Single suggested reply card displayed in Guided support mode.
///
/// Follows AGENTS.md §8:
/// - Lavender fill and purple outline matching the design screenshot
/// - Bold target language text with natural wrapping
/// - 48dp minimum touch target
/// - TODO(question: immediate send vs populating input field)
class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  final Suggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      label: 'Suggested reply: ${suggestion.text}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 48.0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: 13.0,
            ),
            decoration: BoxDecoration(
              color: palette.isDark ? palette.surfaceVariant : palette.brandTint,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: palette.brand, width: 1.5),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              suggestion.text,
              style: AppTypography.bodyMedium.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

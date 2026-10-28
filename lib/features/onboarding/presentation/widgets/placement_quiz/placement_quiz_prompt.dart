import 'package:flutter/material.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/core/theme/app_spacing.dart';
import 'package:peddi/core/theme/app_typography.dart';

/// Question prompt presentation with audio playback and optional warning callout.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, responsive padding and typography.
class PlacementQuizPrompt extends StatelessWidget {
  const PlacementQuizPrompt({
    super.key,
    required this.prompt,
    required this.targetPhrase,
    required this.onSpeak,
    this.pebbiWarning,
  });

  final String prompt;
  final String targetPhrase;
  final VoidCallback onSpeak;
  final String? pebbiWarning;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prompt,
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: OutlinedButton.icon(
            key: const Key('placement_hear_it_button'),
            onPressed: onSpeak,
            icon: const Icon(Icons.volume_up_rounded, size: 20.0),
            label: Text('Hear it: "$targetPhrase"'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandPurple,
              side: const BorderSide(color: AppColors.brandPurpleLight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
        ),
        if (pebbiWarning != null && pebbiWarning!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.noticeWarningBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.coral.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.coral,
                  size: 20.0,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(pebbiWarning!, style: AppTypography.bodyMedium),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

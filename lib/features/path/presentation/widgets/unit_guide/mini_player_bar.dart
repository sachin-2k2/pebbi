import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/guide_phrase.dart';

/// Floating mini audio playback bar pinned to the bottom of the guidebook sheet.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, responsive constraints, safe-area padded.
class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({
    super.key,
    required this.phrase,
    required this.currentIndex,
    required this.totalPhrases,
    required this.onStopPressed,
  });

  final GuidePhrase phrase;
  final int currentIndex;
  final int totalPhrases;
  final VoidCallback onStopPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final counterText = AppStrings.miniPlayerPhraseOf(
      currentIndex + 1,
      totalPhrases,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: palette.outline, width: 1.0),
        boxShadow: palette.cardShadow,
      ),
      child: Row(
        children: [
          Icon(Icons.graphic_eq_rounded, size: 22.0, color: palette.brand),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  phrase.targetText,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  counterText,
                  style: AppTypography.caption.copyWith(
                    fontSize: 12.0,
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Button3D(
            label: AppStrings.stopListening,
            onPressed: onStopPressed,
            width: 88.0,
            isFullWidth: false,
            minHeight: 36.0,
            depth: AppSpacing.depthSm,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            backgroundColor: palette.brand,
            depthColor: palette.brandDepth,
            icon: Icon(
              Icons.stop_rounded,
              size: 16.0,
              color: palette.textOnBrand,
            ),
          ),
        ],
      ),
    );
  }
}

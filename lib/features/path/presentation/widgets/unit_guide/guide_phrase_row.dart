import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/guide_phrase.dart';

/// Single interactive key phrase row inside the unit guidebook.
///
/// Follows AGENTS.md §3 & §4: min 48dp tap target, full semantics, zero raw colors.
class GuidePhraseRow extends StatelessWidget {
  const GuidePhraseRow({
    super.key,
    required this.phrase,
    required this.isPlaying,
    required this.onTap,
    this.showHelperLine = false,
  });

  final GuidePhrase phrase;
  final bool isPlaying;
  final VoidCallback onTap;
  final bool showHelperLine;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final direction = phrase.isRtl ? TextDirection.rtl : TextDirection.ltr;

    final bg = isPlaying ? palette.playingRowFill : palette.surface;
    final border = isPlaying
        ? Border.all(color: palette.playingRowBorder, width: 2.0)
        : Border.all(color: palette.outline, width: 1.0);

    final meaningColor = isPlaying
        ? palette.playingRowMutedText
        : palette.textMuted;

    return Semantics(
      button: true,
      label: isPlaying
          ? 'Playing. ${AppStrings.phraseSemantics(phrase: phrase.targetText, meaning: phrase.meaning)}'
          : AppStrings.phraseSemantics(
              phrase: phrase.targetText,
              meaning: phrase.meaning,
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusIconTile),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56.0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusIconTile),
              border: border,
              boxShadow: isPlaying ? null : palette.cardShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: direction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          phrase.targetText,
                          style: AppTypography.cardTitle.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16.0,
                          ),
                        ),
                        if (showHelperLine && phrase.helperLine != null) ...[
                          const SizedBox(height: 2.0),
                          Text(
                            phrase.helperLine!,
                            style: AppTypography.caption.copyWith(
                              color: palette.brandText,
                              fontStyle: FontStyle.italic,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                        if (phrase.meaning.isNotEmpty) ...[
                          const SizedBox(height: 2.0),
                          Text(
                            phrase.meaning,
                            style: AppTypography.caption.copyWith(
                              color: meaningColor,
                              fontSize: 13.0,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  isPlaying
                      ? Icons.graphic_eq_rounded
                      : Icons.volume_up_outlined,
                  size: 20.0,
                  color: isPlaying
                      ? palette.playingRowBorder
                      : palette.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

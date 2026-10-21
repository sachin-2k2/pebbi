import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/phrase.dart';

/// Interactive card tile displaying a learned phrase with audio and bookmark actions.
///
/// Follows AGENTS.md §3 (<150 lines, build <50 lines) and §4.6.
class PhraseTile extends StatelessWidget {
  const PhraseTile({
    super.key,
    required this.phrase,
    this.showHelperLine = true,
    required this.onTap,
    required this.onToggleSave,
    required this.onPlayAudio,
    this.isPlayingAudio = false,
  });

  final Phrase phrase;
  final bool showHelperLine;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;
  final VoidCallback onPlayAudio;
  final bool isPlayingAudio;

  bool get _isRtl =>
      phrase.languageCode == 'ar' || phrase.languageCode.startsWith('ar-');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final targetColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final meaningColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Semantics(
      button: true,
      label: '${phrase.targetText}, ${phrase.meaning}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: border, width: 1.0),
              boxShadow: isDark ? null : AppSpacing.cardShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AudioButton(isPlaying: isPlayingAudio, onPressed: onPlayAudio),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        phrase.targetText,
                        textDirection: _isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: targetColor,
                        ),
                      ),
                      if (showHelperLine && phrase.helperLine != null) ...[
                        const SizedBox(height: 2.0),
                        Text(
                          phrase.helperLine!,
                          style: TextStyle(
                            fontSize: 13.0,
                            fontStyle: FontStyle.italic,
                            color: meaningColor,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        phrase.meaning,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 14.0,
                          color: meaningColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _StatusTag(status: phrase.status),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _StarButton(isSaved: phrase.isSaved, onPressed: onToggleSave),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioButton extends StatelessWidget {
  const _AudioButton({required this.isPlaying, required this.onPressed});

  final bool isPlaying;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isPlaying ? AppStrings.playingAudio : AppStrings.playAudio,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: AppColors.tintLavender,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            alignment: Alignment.center,
            child: Icon(
              isPlaying ? Icons.volume_up_rounded : Icons.volume_up_outlined,
              size: 22.0,
              color: AppColors.brandPurple,
            ),
          ),
        ),
      ),
    );
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({required this.isSaved, required this.onPressed});

  final bool isSaved;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark
        ? AppColors.darkPhraseTileStarInactive
        : AppColors.phraseTileStarInactive;
    final activeColor = AppColors.phraseTileStarActive;

    return Semantics(
      button: true,
      label: isSaved
          ? AppStrings.savedPhraseSemantics
          : AppStrings.savePhraseSemantics,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
        child: IconButton(
          icon: Icon(
            isSaved ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isSaved ? activeColor : inactiveColor,
            size: 24.0,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});

  final PhraseStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case PhraseStatus.tricky:
        bg = AppColors.statusTagTrickyBackground;
        fg = AppColors.statusTagTrickyText;
        label = AppStrings.phraseStatusTricky;
        break;
      case PhraseStatus.newPhrase:
        bg = AppColors.statusTagNewBackground;
        fg = AppColors.statusTagNewText;
        label = AppStrings.phraseStatusNew;
        break;
      case PhraseStatus.mastered:
      case PhraseStatus.none:
        bg = AppColors.tintLavender;
        fg = AppColors.brandPurple;
        label = AppStrings.phraseStatusMastered;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

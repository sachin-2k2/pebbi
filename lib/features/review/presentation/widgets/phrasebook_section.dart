import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/layout/adaptive_sheet.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/phrase.dart';
import '../../domain/phrase_filter.dart';
import '../../domain/review_segment.dart';
import '../providers/review_provider.dart';
import 'phrase_detail_sheet.dart';
import 'phrase_tile.dart';
import 'saved_count_badge.dart';

/// Phrasebook section displaying the user's saved phrases or an introductory note when empty.
///
/// Follows AGENTS.md §3 (<150 lines, build <50 lines) and §6.
class PhrasebookSection extends ConsumerStatefulWidget {
  const PhrasebookSection({super.key});

  @override
  ConsumerState<PhrasebookSection> createState() => _PhrasebookSectionState();
}

class _PhrasebookSectionState extends ConsumerState<PhrasebookSection> {
  String? _currentlyPlayingId;

  Future<void> _playAudio(Phrase phrase) async {
    setState(() => _currentlyPlayingId = phrase.id);
    final tts = ref.read(textToSpeechServiceProvider);
    await tts.speak(
      phrase.targetText,
      locale: phrase.languageCode == 'es' ? 'es-ES' : phrase.languageCode,
    );
    if (mounted) {
      setState(() => _currentlyPlayingId = null);
    }
  }

  void _openDetail(Phrase phrase) {
    AdaptiveSheet.show(
      context: context,
      builder: (_) => PhraseDetailSheet(phrase: phrase),
    );
  }

  void _seeAllSaved() {
    ref.read(phraseFilterProvider.notifier).state = PhraseFilter.saved;
    ref.read(reviewSegmentProvider.notifier).state = ReviewSegment.phrases;
  }

  @override
  Widget build(BuildContext context) {
    final savedPhrases = ref.watch(savedPhrasesProvider);
    final showHelper = ref.watch(showHelperLineProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayedPhrases = savedPhrases.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                AppStrings.phrasebookTitle,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SavedCountBadge(count: savedPhrases.length),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (savedPhrases.isEmpty)
          const _EmptyPhrasebookNote()
        else ...[
          for (final phrase in displayedPhrases) ...[
            PhraseTile(
              phrase: phrase,
              showHelperLine: showHelper,
              isPlayingAudio: _currentlyPlayingId == phrase.id,
              onTap: () => _openDetail(phrase),
              onToggleSave: () async {
                final repo = ref.read(phraseRepositoryProvider);
                await repo.toggleSaved(phrase.id);
                ref.invalidate(phrasesListProvider);
              },
              onPlayAudio: () => _playAudio(phrase),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (savedPhrases.length > 3)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _seeAllSaved,
                child: Text(
                  AppStrings.seeAllSavedPhrases,
                  style: const TextStyle(
                    color: AppColors.brandPurple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _EmptyPhrasebookNote extends StatelessWidget {
  const _EmptyPhrasebookNote();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkNoteCardBackground
        : AppColors.noteCardBackground;
    final border = isDark
        ? AppColors.darkNoteCardBorder
        : AppColors.noteCardBorder;
    final textColor = isDark
        ? AppColors.darkNoteCardText
        : AppColors.noteCardText;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Text(
        AppStrings.phrasebookEmptyNote,
        style: TextStyle(
          color: textColor,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
      ),
    );
  }
}

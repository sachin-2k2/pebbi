import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/layout/adaptive_sheet.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/phrase.dart';
import '../providers/review_provider.dart';
import 'phrase_count_line.dart';
import 'phrase_detail_sheet.dart';
import 'phrase_filter_chips.dart';
import 'phrase_list.dart';
import 'phrases_empty_state.dart';
import 'practise_tricky_button.dart';

/// Presentation widget composing the "Phrases" sub-tab view.
///
/// Follows AGENTS.md §3 (<150 lines, build <50 lines) and §4.
class PhrasesTab extends ConsumerStatefulWidget {
  const PhrasesTab({super.key});

  @override
  ConsumerState<PhrasesTab> createState() => _PhrasesTabState();
}

class _PhrasesTabState extends ConsumerState<PhrasesTab> {
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

  void _showNoTrickyNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.practiseTrickyNoPhrasesMessage),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openDetail(Phrase phrase) {
    AdaptiveSheet.show(
      context: context,
      builder: (_) => PhraseDetailSheet(phrase: phrase),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(phraseFilterProvider);
    final phrases = ref.watch(filteredPhrasesProvider);
    final summary = ref.watch(reviewSummaryProvider);
    final showHelper = ref.watch(showHelperLineProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        PractiseTrickyButton(
          trickyCount: summary.trickyCount,
          onStartPractice: () => context.push('/review/practice?mode=tricky'),
          onNoTrickyPhrases: _showNoTrickyNotice,
        ),
        const SizedBox(height: AppSpacing.md),
        PhraseFilterChips(
          selectedFilter: filter,
          onFilterSelected: (newFilter) {
            ref.read(phraseFilterProvider.notifier).state = newFilter;
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        PhraseCountLine(count: phrases.length),
        const SizedBox(height: AppSpacing.md),
        if (phrases.isEmpty)
          PhrasesEmptyState(activeFilter: filter)
        else
          PhraseList(
            phrases: phrases,
            showHelperLine: showHelper,
            currentlyPlayingPhraseId: _currentlyPlayingId,
            onTapPhrase: _openDetail,
            onToggleSave: (phrase) async {
              final repo = ref.read(phraseRepositoryProvider);
              await repo.toggleSaved(phrase.id);
              ref.invalidate(phrasesListProvider);
            },
            onPlayAudio: _playAudio,
          ),
      ],
    );
  }
}

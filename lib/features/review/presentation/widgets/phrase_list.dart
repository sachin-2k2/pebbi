import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/phrase.dart';
import 'phrase_tile.dart';

/// Virtualized list rendering phrases with smooth scrolling and high item-count scaling.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.4 (ListView.builder).
class PhraseList extends StatelessWidget {
  const PhraseList({
    super.key,
    required this.phrases,
    required this.showHelperLine,
    required this.currentlyPlayingPhraseId,
    required this.onTapPhrase,
    required this.onToggleSave,
    required this.onPlayAudio,
  });

  final List<Phrase> phrases;
  final bool showHelperLine;
  final String? currentlyPlayingPhraseId;
  final ValueChanged<Phrase> onTapPhrase;
  final ValueChanged<Phrase> onToggleSave;
  final ValueChanged<Phrase> onPlayAudio;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: phrases.length,
      itemBuilder: (context, index) {
        final phrase = phrases[index];
        return Padding(
          key: ValueKey(phrase.id),
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: PhraseTile(
            phrase: phrase,
            showHelperLine: showHelperLine,
            isPlayingAudio: phrase.id == currentlyPlayingPhraseId,
            onTap: () => onTapPhrase(phrase),
            onToggleSave: () => onToggleSave(phrase),
            onPlayAudio: () => onPlayAudio(phrase),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../domain/exercise.dart';
import '../../../../domain/phrase_token.dart';
import 'pebbi_tip_row.dart';
import 'phrase_card.dart';
import 'phrase_tag_row.dart';
import 'phrasebook_hint_text.dart';

/// Layout composition for the content inside [NewPhraseCardBody].
///
/// Follows AGENTS.md §3 & §4: under 80 lines, build under 50 lines.
class NewPhraseCardBodyContent extends StatelessWidget {
  const NewPhraseCardBodyContent({
    super.key,
    required this.exercise,
    required this.savedTokenIds,
    required this.isPlaying,
    required this.onTokenTap,
    required this.onNormal,
    required this.onSlow,
  });

  final NewPhraseCardExercise exercise;
  final Set<String> savedTokenIds;
  final bool isPlaying;
  final ValueChanged<PhraseToken> onTokenTap;
  final VoidCallback onNormal;
  final VoidCallback onSlow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PhraseTagRow(
          phraseKindTag: exercise.phraseKindTag,
          registerTag: exercise.registerTag,
        ),
        const SizedBox(height: AppSpacing.md),
        PhraseCard(
          picture: exercise.picture,
          tokens: exercise.tokens,
          meaning: exercise.meaning,
          savedTokenIds: savedTokenIds,
          onTokenTap: onTokenTap,
          onNormal: onNormal,
          onSlow: onSlow,
          isPlaying: isPlaying,
        ),
        const SizedBox(height: AppSpacing.lg),
        PebbiTipRow(tipText: exercise.tipText),
        const SizedBox(height: AppSpacing.md),
        const PhrasebookHintText(),
      ],
    );
  }
}

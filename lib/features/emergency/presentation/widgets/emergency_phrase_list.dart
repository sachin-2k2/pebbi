import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/emergency_phrase.dart';
import 'emergency_phrase_card.dart';

/// List of emergency phrase cards with spacing.
///
/// Follows AGENTS.md §3 (under 150 lines).
class EmergencyPhraseList extends StatelessWidget {
  const EmergencyPhraseList({
    super.key,
    required this.phrases,
    required this.explanationLanguageCode,
    required this.targetLanguageName,
    required this.targetLanguageCode,
    required this.onPhraseTap,
    this.onPhraseIndexTap,
    this.showHelperLine = false,
  });

  final List<EmergencyPhrase> phrases;
  final String explanationLanguageCode;
  final String targetLanguageName;
  final String targetLanguageCode;
  final ValueChanged<EmergencyPhrase> onPhraseTap;
  final void Function(EmergencyPhrase phrase, int index)? onPhraseIndexTap;
  final bool showHelperLine;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < phrases.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          EmergencyPhraseCard(
            phrase: phrases[i],
            explanationLanguageCode: explanationLanguageCode,
            targetLanguageName: targetLanguageName,
            targetLanguageCode: targetLanguageCode,
            showHelperLine: showHelperLine,
            onTap: () {
              if (onPhraseIndexTap != null) {
                onPhraseIndexTap!(phrases[i], i);
              } else {
                onPhraseTap(phrases[i]);
              }
            },
          ),
        ],
      ],
    );
  }
}

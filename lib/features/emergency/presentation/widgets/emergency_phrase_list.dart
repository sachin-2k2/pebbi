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
    this.showHelperLine = false,
  });

  final List<EmergencyPhrase> phrases;
  final String explanationLanguageCode;
  final String targetLanguageName;
  final String targetLanguageCode;
  final ValueChanged<EmergencyPhrase> onPhraseTap;
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
            onTap: () => onPhraseTap(phrases[i]),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/design_system/back_link.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/emergency_phrase.dart';
import '../../domain/emergency_phrasebook.dart';
import 'emergency_header.dart';
import 'emergency_note.dart';
import 'emergency_phrase_list.dart';

/// Loaded content body for the emergency phrasebook screen.
///
/// Follows AGENTS.md §3 (<100 lines) and §4.1 (responsive, max width 640).
class EmergencyLoadedBody extends StatelessWidget {
  const EmergencyLoadedBody({
    super.key,
    required this.phrasebook,
    required this.explanationLang,
    required this.showHelper,
    required this.onBack,
    required this.onPhraseTap,
  });

  final EmergencyPhrasebook phrasebook;
  final String explanationLang;
  final bool showHelper;
  final VoidCallback onBack;
  final void Function(EmergencyPhrase phrase, int index) onPhraseTap;

  @override
  Widget build(BuildContext context) {
    return ContentWidthLimiter(
      maxWidth: 640,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        children: [
          BackLink(label: AppStrings.missionsLink, onTap: onBack),
          const SizedBox(height: AppSpacing.sm),
          EmergencyHeader(
            title: phrasebook.title,
            subtitle: phrasebook.subtitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          EmergencyPhraseList(
            phrases: phrasebook.phrases,
            explanationLanguageCode: explanationLang,
            targetLanguageName: phrasebook.languageName,
            targetLanguageCode: phrasebook.languageCode,
            showHelperLine: showHelper,
            onPhraseTap: (p) => onPhraseTap(p, 0),
            onPhraseIndexTap: (p, idx) => onPhraseTap(p, idx),
          ),
          const SizedBox(height: AppSpacing.xl),
          EmergencyNote(
            targetLanguageName: phrasebook.languageName,
            customMessage: phrasebook.disclaimer,
          ),
          const SizedBox(height: AppSpacing.xl),
          Button3D.secondary(
            label: AppStrings.emergencyBackToMissions,
            onPressed: onBack,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}


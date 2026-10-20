import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/emergency_phrase.dart';

/// Single rose-fill emergency phrase card with red meaning label and bold target phrase.
///
/// Follows AGENTS.md §3 (under 150 lines), §4.6 (flexible sizing), & WCAG AA:
/// - Red label uses [AppColors.emergencyLabelRed] (5.81:1 contrast on rose).
/// - Distinct text direction support for RTL labels (Arabic, Urdu) and target text.
/// - Consolidated button semantics with language-tagged pronunciation context.
class EmergencyPhraseCard extends StatelessWidget {
  const EmergencyPhraseCard({
    super.key,
    required this.phrase,
    required this.explanationLanguageCode,
    required this.targetLanguageName,
    required this.targetLanguageCode,
    required this.onTap,
    this.showHelperLine = false,
  });

  final EmergencyPhrase phrase;
  final String explanationLanguageCode;
  final String targetLanguageName;
  final String targetLanguageCode;
  final VoidCallback onTap;
  final bool showHelperLine;

  static bool _isRtl(String langCode) =>
      langCode == 'ar' ||
      langCode == 'ur' ||
      langCode == 'he' ||
      langCode == 'fa';

  @override
  Widget build(BuildContext context) {
    final meaning = phrase.getLabel(explanationLanguageCode);
    final labelDir = _isRtl(explanationLanguageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
    final targetDir = _isRtl(targetLanguageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;

    final semanticsLabel = AppStrings.emergencyPhraseCardSemantics(
      meaning: meaning,
      languageName: targetLanguageName,
      phrase: phrase.targetText,
    );

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: AppColors.emergencyCardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(
                color: AppColors.emergencyCardBorder,
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Explanation Language Meaning Label (Red, bold)
                Directionality(
                  textDirection: labelDir,
                  child: Text(
                    meaning,
                    style: const TextStyle(
                      color: AppColors.emergencyLabelRed,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                // Target Language Phrase (Larger, bold, dark plain font)
                Directionality(
                  textDirection: targetDir,
                  child: Text(
                    phrase.targetText,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
                if (showHelperLine &&
                    phrase.helperLine != null &&
                    phrase.helperLine!.isNotEmpty) ...[
                  const SizedBox(height: 2.0),
                  Text(phrase.helperLine!, style: AppTypography.caption),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/emergency_phrase.dart';
import 'phrase_display_text.dart';

/// Dark high-contrast card for the emergency show-screen view.
///
/// Follows AGENTS.md §3 (<150 lines) and backend specifications:
/// - Big bold translation in learning language for arm's length visibility.
/// - Small native text below in the learner's native language.
class ShowScreenPagerCard extends StatelessWidget {
  const ShowScreenPagerCard({
    super.key,
    required this.phrase,
    required this.explanationLanguageCode,
    required this.targetLanguageCode,
    this.showHelperLine = false,
  });

  final EmergencyPhrase phrase;
  final String explanationLanguageCode;
  final String targetLanguageCode;
  final bool showHelperLine;

  @override
  Widget build(BuildContext context) {
    final nativeText = phrase.getLabel(explanationLanguageCode);

    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: AppColors.darkEmergencyCardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(
            color: AppColors.darkEmergencyCardBorder,
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Big bold target text for local responders
            PhraseDisplayText(
              phrase: phrase,
              targetLanguageCode: targetLanguageCode,
              showHelperLine: showHelperLine,
              textColor: Colors.white,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Small native text for learner reference
            Text(
              nativeText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkEmergencyLabelRed,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

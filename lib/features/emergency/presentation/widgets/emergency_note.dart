import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';

/// Soft lavender-grey note card with dynamic language parameter and high-contrast text.
///
/// Follows AGENTS.md §3 & WCAG AAA:
/// - Dynamic target language name parameter (never hardcoded).
/// - Contrast ratio exceeds 10:1.
class EmergencyNote extends StatelessWidget {
  const EmergencyNote({super.key, required this.targetLanguageName});

  final String targetLanguageName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.emergencyNoteBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Text(
        AppStrings.emergencyNoteMessage(targetLanguageName),
        style: const TextStyle(
          color: AppColors.emergencyNoteText,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }
}

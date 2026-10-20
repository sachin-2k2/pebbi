import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Placeholder screen for the Emergency Phrasebook.
///
/// TODO(question: build the 8 offline survival phrases, audio playback, and wakelock keep-awake screen).
class EmergencyPhrasebookPlaceholderScreen extends StatelessWidget {
  const EmergencyPhrasebookPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.emergencyPhrasebookLabel),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Emergency Phrasebook',
                  style: AppTypography.screenTitle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  '8 survival phrases, full screen audio playback, offline ready.\n(Coming soon)',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

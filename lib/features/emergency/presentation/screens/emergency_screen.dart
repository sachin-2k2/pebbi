import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/emergency_phrase.dart';
import '../providers/emergency_provider.dart';
import '../widgets/emergency_loaded_body.dart';
import '../widgets/emergency_unavailable_state.dart';
import '../widgets/show_screen_view.dart';

/// Emergency Phrasebook screen displaying 8 life-critical phrases offline.
///
/// Follows AGENTS.md §3.1 (<100 lines), §4.1 (responsive, max width 640),
/// §5.1 (100% offline-first), and §7.3.
class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _openShowScreen({
    required BuildContext context,
    required List<EmergencyPhrase> phrases,
    required int initialIndex,
    required String explanationLanguageCode,
    required String targetLanguageCode,
    required String targetLanguageName,
    required bool showHelperLine,
    String? disclaimer,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ShowScreenView(
          phrases: phrases,
          initialIndex: initialIndex,
          explanationLanguageCode: explanationLanguageCode,
          targetLanguageCode: targetLanguageCode,
          targetLanguageName: targetLanguageName,
          showHelperLine: showHelperLine,
          disclaimer: disclaimer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phrasebookAsync = ref.watch(emergencyPhrasebookProvider);
    final explanationLang = ref.watch(emergencyExplanationLanguageProvider);
    final showHelper = ref.watch(emergencyShowHelperLineProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: phrasebookAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (err, stack) =>
              EmergencyUnavailableState(onBack: () => _handleBack(context)),
          data: (phrasebook) {
            if (phrasebook == null || !phrasebook.isReviewed) {
              return EmergencyUnavailableState(
                onBack: () => _handleBack(context),
              );
            }
            return EmergencyLoadedBody(
              phrasebook: phrasebook,
              explanationLang: explanationLang,
              showHelper: showHelper,
              onBack: () => _handleBack(context),
              onPhraseTap: (phrase, index) => _openShowScreen(
                context: context,
                phrases: phrasebook.phrases,
                initialIndex: index,
                explanationLanguageCode: explanationLang,
                targetLanguageCode: phrasebook.languageCode,
                targetLanguageName: phrasebook.languageName,
                showHelperLine: showHelper,
                disclaimer: phrasebook.disclaimer,
              ),
            );
          },
        ),
      ),
    );
  }
}

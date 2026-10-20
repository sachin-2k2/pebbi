import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/back_link.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/emergency_phrase.dart';
import '../../domain/emergency_phrasebook.dart';
import '../providers/emergency_provider.dart';
import '../widgets/emergency_header.dart';
import '../widgets/emergency_note.dart';
import '../widgets/emergency_phrase_list.dart';
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
    required EmergencyPhrase phrase,
    required String explanationLanguageCode,
    required String targetLanguageCode,
    required bool showHelperLine,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ShowScreenView(
          phrase: phrase,
          explanationLanguageCode: explanationLanguageCode,
          targetLanguageCode: targetLanguageCode,
          showHelperLine: showHelperLine,
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
            return _EmergencyLoadedBody(
              phrasebook: phrasebook,
              explanationLang: explanationLang,
              showHelper: showHelper,
              onBack: () => _handleBack(context),
              onPhraseTap: (phrase) => _openShowScreen(
                context: context,
                phrase: phrase,
                explanationLanguageCode: explanationLang,
                targetLanguageCode: phrasebook.languageCode,
                showHelperLine: showHelper,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmergencyLoadedBody extends StatelessWidget {
  const _EmergencyLoadedBody({
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
  final ValueChanged<EmergencyPhrase> onPhraseTap;

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
          const EmergencyHeader(),
          const SizedBox(height: AppSpacing.lg),
          EmergencyPhraseList(
            phrases: phrasebook.phrases,
            explanationLanguageCode: explanationLang,
            targetLanguageName: phrasebook.languageName,
            targetLanguageCode: phrasebook.languageCode,
            showHelperLine: showHelper,
            onPhraseTap: onPhraseTap,
          ),
          const SizedBox(height: AppSpacing.xl),
          EmergencyNote(targetLanguageName: phrasebook.languageName),
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

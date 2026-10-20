import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/learnable_language.dart';
import '../providers/onboarding_flow_provider.dart';
import '../widgets/learn_language_grid.dart';
import '../widgets/step_footer_button.dart';
import '../widgets/step_progress_header.dart';
import '../widgets/step_scaffold.dart';
import '../widgets/step_title_block.dart';

/// Onboarding Setup Step 4 of 11: "I want to learn...".
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// equal-height rows, responsive card grid, and TTS preview.
class LearnLanguageStepScreen extends ConsumerStatefulWidget {
  const LearnLanguageStepScreen({
    super.key,
    this.initialCode,
    this.onContinue,
    this.onBack,
  });

  final String? initialCode;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  @override
  ConsumerState<LearnLanguageStepScreen> createState() =>
      _LearnLanguageStepScreenState();
}

class _LearnLanguageStepScreenState
    extends ConsumerState<LearnLanguageStepScreen> {
  late String _selectedCode;
  late final TextToSpeechService _ttsService;

  @override
  void initState() {
    super.initState();
    _ttsService = ref.read(textToSpeechServiceProvider);
    _selectedCode =
        widget.initialCode ??
        ref.read(onboardingFlowProvider).targetLanguageCode;
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _handleSelectLanguage(LearnableLanguage language) async {
    if (!language.isAvailable) {
      // TODO(question): Client has not confirmed coming soon card tap feedback.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(AppStrings.comingSoonFeedback),
            duration: Duration(seconds: 1),
          ),
        );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _selectedCode = language.code);

    final success = await ref
        .read(textToSpeechServiceProvider)
        .speak(language.helloText, locale: language.ttsLocale);

    if (!success && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(AppStrings.voiceNotAvailable),
            duration: Duration(seconds: 2),
          ),
        );
    }
  }

  void _handleContinue() {
    final notifier = ref.read(onboardingFlowProvider.notifier);
    notifier.setTargetLanguageCode(_selectedCode);
    notifier.setStep(4);

    final explanationCode = ref
        .read(onboardingFlowProvider)
        .explanationLanguageCode;
    if (_selectedCode == explanationCode) {
      // TODO(question): Target language matches native explanation language from step 3.
    }

    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      context.go('/onboarding/setup/step-5');
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/onboarding/setup/step-3');
    }
  }

  @override
  Widget build(BuildContext context) {
    final languages = ref.watch(learnableLanguagesProvider);

    return StepScaffold(
      header: StepProgressHeader(currentStep: 4, onBack: _handleBack),
      footer: StepFooterButton(onPressed: _handleContinue),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepTitleBlock(
            title: AppStrings.iWantToLearnTitle,
            subtitle: AppStrings.iWantToLearnSubtitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          LearnLanguageGrid(
            languages: languages,
            selectedCode: _selectedCode,
            onSelect: _handleSelectLanguage,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

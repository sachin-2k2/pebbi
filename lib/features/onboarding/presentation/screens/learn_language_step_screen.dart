import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/design_system/empty_state.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../../../core/theme/app_colors.dart';
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
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// equal-height rows, responsive card grid, TTS preview, and no-courses/offline handling.
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
  String _selectedCode = '';
  late final TextToSpeechService _ttsService;

  @override
  void initState() {
    super.initState();
    _ttsService = ref.read(textToSpeechServiceProvider);
    final savedCode = ref.read(onboardingFlowProvider).targetLanguageCode;
    _selectedCode = widget.initialCode ?? (savedCode.isNotEmpty ? savedCode : '');
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _handleSelectLanguage(LearnableLanguage language) async {
    if (!language.isAvailable) return;

    HapticFeedback.lightImpact();
    setState(() => _selectedCode = language.code);

    try {
      await ref.read(textToSpeechServiceProvider).speak(
            language.helloText,
            locale: language.ttsLocale,
          );
    } catch (_) {
      // Fail quietly if voice synthesis fails
    }
  }

  void _handleContinue(List<LearnableLanguage> languages) {
    if (_selectedCode.isEmpty) return;
    final chosen = languages.firstWhere(
      (l) => l.code == _selectedCode,
      orElse: () => languages.first,
    );

    final notifier = ref.read(onboardingFlowProvider.notifier);
    notifier.setTargetLanguageCode(
      chosen.code,
      hasPlacement: chosen.hasPlacement,
    );
    notifier.setStep(4);

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
    final nativeCode = ref.watch(
      onboardingFlowProvider.select((s) => s.explanationLanguageCode),
    );
    final asyncVal = ref.watch(learnLanguagesProvider(nativeCode));

    return asyncVal.when(
      loading: () => StepScaffold(
        header: StepProgressHeader(currentStep: 4, onBack: _handleBack),
        body: const Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (e, _) => StepScaffold(
        header: StepProgressHeader(currentStep: 4, onBack: _handleBack),
        body: EmptyState(
          illustration: const Icon(
            Icons.wifi_off_rounded,
            size: 56.0,
            color: AppColors.textMuted,
          ),
          title: "You're offline",
          subtitle: 'Connect to the internet to see available courses.',
          action: Button3D(
            label: 'Retry',
            onPressed: () =>
                ref.read(learnLanguagesProvider(nativeCode).notifier).load(),
          ),
        ),
      ),
      data: (languages) {
        final selectable = languages.where((l) => l.isAvailable).toList();
        if (_selectedCode.isEmpty && selectable.length == 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedCode.isEmpty) {
              setState(() => _selectedCode = selectable.first.code);
            }
          });
        } else if (_selectedCode.isNotEmpty &&
            !selectable.any((l) => l.code == _selectedCode)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() =>
                  _selectedCode = selectable.length == 1
                      ? selectable.first.code
                      : '');
            }
          });
        }

        if (selectable.isEmpty) {
          return StepScaffold(
            header: StepProgressHeader(currentStep: 4, onBack: _handleBack),
            body: EmptyState(
              illustration: const Icon(
                Icons.school_outlined,
                size: 56.0,
                color: AppColors.textMuted,
              ),
              title: AppStrings.noCoursesTitle,
              subtitle: 'No courses available for your spoken language yet.',
              action: Button3D(
                label: AppStrings.changeSpokenLanguageAction,
                onPressed: _handleBack,
              ),
            ),
          );
        }

        return StepScaffold(
          header: StepProgressHeader(currentStep: 4, onBack: _handleBack),
          footer: StepFooterButton(
            isEnabled: _selectedCode.isNotEmpty,
            onPressed: _selectedCode.isNotEmpty
                ? () => _handleContinue(languages)
                : null,
          ),
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
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/notice_banner.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../providers/onboarding_flow_provider.dart';
import '../widgets/language_chip_wrap.dart';
import '../widgets/language_search_field.dart';
import '../widgets/step_footer_button.dart';
import '../widgets/step_progress_header.dart';
import '../widgets/step_scaffold.dart';
import '../widgets/step_title_block.dart';

/// Onboarding Setup Step 3 of 11: "I speak...".
///
/// Follows AGENTS.md §3 and §4: under 120 lines, build under 50 lines.
/// Reuses shared onboarding frame with data-driven yellow notice banner.
class LanguageStepScreen extends ConsumerStatefulWidget {
  const LanguageStepScreen({
    super.key,
    this.initialCode = 'en',
    this.onContinue,
    this.onBack,
  });

  final String initialCode;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  @override
  ConsumerState<LanguageStepScreen> createState() => _LanguageStepScreenState();
}

class _LanguageStepScreenState extends ConsumerState<LanguageStepScreen> {
  late final TextEditingController _searchController;
  late String _selectedCode;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.initialCode;
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    ref
        .read(onboardingFlowProvider.notifier)
        .setExplanationLanguageCode(_selectedCode);
    ref.read(onboardingFlowProvider.notifier).setStep(3);
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      context.go('/onboarding/setup/step-4');
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/onboarding/setup/step-2');
    }
  }

  @override
  Widget build(BuildContext context) {
    final allLanguages = ref.watch(explanationLanguagesProvider);
    final filteredLanguages = allLanguages
        .where((l) => l.matches(_searchQuery))
        .toList();
    final selectedLang = allLanguages.firstWhere(
      (l) => l.code == _selectedCode,
      orElse: () => allLanguages.first,
    );
    final showNotice = !selectedLang.translationsReviewed;
    final disableAnim = MediaQuery.of(context).disableAnimations;

    return StepScaffold(
      // TODO(question): Header bar (3/11) was omitted from step 3 screenshots; retained for consistency.
      header: StepProgressHeader(currentStep: 3, onBack: _handleBack),
      footer: StepFooterButton(onPressed: _handleContinue),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepTitleBlock(
            title: AppStrings.iSpeakTitle,
            subtitle: AppStrings.iSpeakSubtitle,
          ),
          LanguageSearchField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: AppSpacing.lg),
          LanguageChipWrap(
            languages: filteredLanguages,
            selectedCode: _selectedCode,
            onSelect: (code) => setState(() => _selectedCode = code),
          ),
          AnimatedSize(
            duration: disableAnim
                ? Duration.zero
                : const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: showNotice
                ? const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.lg),
                    child: NoticeBanner(
                      message: AppStrings.translationsPendingNotice,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

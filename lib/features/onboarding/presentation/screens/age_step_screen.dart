import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/age_band.dart';
import '../../domain/onboarding_config.dart';
import '../providers/onboarding_flow_provider.dart';
import '../widgets/privacy_note_card.dart';
import '../widgets/section_label.dart';
import '../widgets/step_footer_button.dart';
import '../widgets/step_progress_header.dart';
import '../widgets/step_scaffold.dart';
import '../widgets/step_title_block.dart';
import '../widgets/year_of_birth_field.dart';
import '../widgets/year_picker_sheet.dart';

/// Onboarding Setup Step 2 of 11: "How old are you?".
///
/// Follows AGENTS.md §3 and §6:
/// - Under 100 lines, build under 50 lines.
/// - Raw birth year exists ONLY in this screen's local state.
/// - ONLY the derived [AgeBand] is submitted to the notifier.
class AgeStepScreen extends ConsumerStatefulWidget {
  const AgeStepScreen({
    super.key,
    this.initialYear = OnboardingConfig.defaultBirthYear,
    this.onContinue,
    this.onBack,
  });

  final int initialYear;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  @override
  ConsumerState<AgeStepScreen> createState() => _AgeStepScreenState();
}

class _AgeStepScreenState extends ConsumerState<AgeStepScreen> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
  }

  Future<void> _pickYear() async {
    final picked = await YearPickerSheet.show(
      context: context,
      selectedYear: _selectedYear,
    );
    if (picked != null && mounted) {
      setState(() => _selectedYear = picked);
    }
  }

  void _handleContinue() {
    final band = AgeBand.fromBirthYear(_selectedYear);
    ref.read(onboardingFlowProvider.notifier).setAgeBand(band);
    ref.read(onboardingFlowProvider.notifier).setStep(2);
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      context.go('/onboarding/setup/step-3');
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ageBand = AgeBand.fromBirthYear(_selectedYear);
    final isChild = ageBand == AgeBand.child;
    final mascotExpression = isChild
        ? PebbiExpression.protective
        : PebbiExpression.happy;

    return StepScaffold(
      useIntrinsicHeight: true,
      header: StepProgressHeader(currentStep: 2, onBack: _handleBack),
      footer: StepFooterButton(
        isEnabled: !isChild,
        onPressed: isChild ? null : _handleContinue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepTitleBlock(
            title: AppStrings.howOldAreYouTitle,
            subtitle: AppStrings.howOldAreYouSubtitle,
            mascotExpression: mascotExpression,
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionLabel(text: AppStrings.yearOfBirthLabel),
          const SizedBox(height: AppSpacing.sm),
          YearOfBirthField(year: _selectedYear, onTap: _pickYear),
          const SizedBox(height: AppSpacing.lg),
          PrivacyNoteCard(ageBand: ageBand),
          const Spacer(),
        ],
      ),
    );
  }
}

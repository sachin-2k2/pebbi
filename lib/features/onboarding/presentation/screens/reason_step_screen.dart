import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/reason_selection_rules.dart';
import '../providers/onboarding_flow_provider.dart';
import '../widgets/backpack_hint.dart';
import '../widgets/reason_grid.dart';
import '../widgets/step_bottom_bar.dart';
import '../widgets/step_footer_button.dart';
import '../widgets/step_progress_header.dart';
import '../widgets/step_scaffold.dart';
import '../widgets/step_title_block.dart';

/// Onboarding Setup Step 5 of 11: "Why are you learning?".
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// multi-select (up to 3), dynamic backpack pill, pinned bottom bar.
class ReasonStepScreen extends ConsumerStatefulWidget {
  const ReasonStepScreen({
    super.key,
    this.initialSelectedIds,
    this.onContinue,
    this.onBack,
  });

  final Set<String>? initialSelectedIds;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  @override
  ConsumerState<ReasonStepScreen> createState() => _ReasonStepScreenState();
}

class _ReasonStepScreenState extends ConsumerState<ReasonStepScreen> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds =
        widget.initialSelectedIds ??
        ref.read(onboardingFlowProvider).selectedReasonIds;
  }

  void _handleToggle(String id) {
    if (!_selectedIds.contains(id) &&
        _selectedIds.length >= ReasonSelectionRules.maxSelections) {
      // TODO(question): Confirm whether 4th selection shows message or dims unselected cards.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(AppStrings.maxReasonsReached),
            duration: Duration(seconds: 1),
          ),
        );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _selectedIds = ReasonSelectionRules.toggle(_selectedIds, id);
    });
  }

  void _handleContinue() {
    final notifier = ref.read(onboardingFlowProvider.notifier);
    notifier.setReasonIds(_selectedIds);
    notifier.setStep(5);

    // TODO(question): Minimum selection requirement (0 allowed for now per design).
    // TODO(question): Track mapping ownership (reasons -> Everyday, Travel, Work, Life Abroad, Exams).
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      context.go('/onboarding/setup/step-6');
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/onboarding/setup/step-4');
    }
  }

  @override
  Widget build(BuildContext context) {
    final reasons = ref.watch(learningReasonsProvider);
    final reasonMap = {for (final r in reasons) r.id: r.iconEmoji};
    final selectedEmojis = [
      for (final id in _selectedIds)
        if (reasonMap.containsKey(id)) reasonMap[id]!,
    ];

    return StepScaffold(
      header: StepProgressHeader(currentStep: 5, onBack: _handleBack),
      footer: StepBottomBar(
        topChild: BackpackHint(
          selectedCount: _selectedIds.length,
          selectedEmojis: selectedEmojis,
        ),
        button: StepFooterButton(onPressed: _handleContinue),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepTitleBlock(
            showMascot: false,
            title: AppStrings.whyAreYouLearningTitle,
            subtitle: AppStrings.whyAreYouLearningSubtitle,
          ),
          ReasonGrid(
            reasons: reasons,
            selectedIds: _selectedIds,
            onToggle: _handleToggle,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

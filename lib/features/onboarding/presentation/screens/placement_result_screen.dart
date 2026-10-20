import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/info_card.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/language_level.dart';
import '../../domain/level_info.dart';
import '../providers/onboarding_flow_provider.dart';
import '../providers/placement_result_notifier.dart';
import '../widgets/placement_result/level_picker_sheet.dart';
import '../widgets/placement_result/praised_phrases_card.dart';
import '../widgets/placement_result/result_chip_row.dart';
import '../widgets/placement_result/result_hero.dart';
import '../widgets/step_bottom_bar.dart';
import '../widgets/step_footer_button.dart';
import '../widgets/step_scaffold.dart';

/// Screen presenting placement quiz results, assigned level, and adaptive level picker sheet.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// responsive layout with [ContentWidthLimiter], pinned actions, accessible.
class PlacementResultScreen extends ConsumerWidget {
  const PlacementResultScreen({super.key});

  void _handleSelectLevel(BuildContext context, WidgetRef ref, LevelInfo info) {
    ref.read(placementResultProvider.notifier).selectLevel(info.level);
    SemanticsService.sendAnnouncement(
      View.of(context),
      AppStrings.levelChangedAnnouncement(info.name),
      TextDirection.ltr,
    );
  }

  Future<void> _handleOpenPicker(
    BuildContext context,
    WidgetRef ref,
    LanguageLevel currentLevel,
  ) async {
    final chosen = await LevelPickerSheet.show(
      context: context,
      selectedLevel: currentLevel,
    );
    if (chosen != null && context.mounted) {
      _handleSelectLevel(context, ref, LevelInfo.forLevel(chosen));
    }
  }

  void _handleStart(BuildContext context, WidgetRef ref) {
    final state = ref.read(placementResultProvider);
    ref
        .read(onboardingFlowProvider.notifier)
        .recordPlacementEvaluation(
          state.result.copyWith(chosenLevel: state.chosenLevel),
        );
    context.go('/onboarding/setup/step-7');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(placementResultProvider);
    final levelInfo = state.currentLevelInfo;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/onboarding/setup/step-6');
      },
      child: StepScaffold(
        body: Center(
          child: ContentWidthLimiter(
            maxWidth: 580.0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ResultHero(title: levelInfo.title),
                  const SizedBox(height: AppSpacing.md),
                  ResultChipRow(
                    levelInfo: levelInfo,
                    firstTryCorrect: state.result.firstTryCorrect,
                    totalQuestions: state.result.totalQuestions,
                    streakDay: state.result.streakDay,
                    isScoreVisible: state.result.isScoreChipVisible,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  InfoCard(
                    title: AppStrings.whatHappensNowTitle,
                    body: levelInfo.whatHappensNowText,
                    leadingIcon: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.brandPurple,
                      size: 20.0,
                    ),
                  ),
                  if (state.result.hasPraisePhrases) ...[
                    const SizedBox(height: AppSpacing.md),
                    PraisedPhrasesCard(phrases: state.result.praisePhrases),
                  ],
                ],
              ),
            ),
          ),
        ),
        bottomBar: StepBottomBar(
          button: StepFooterButton(
            label: AppStrings.startFromHere,
            onPressed: () => _handleStart(context, ref),
            secondaryLabel: AppStrings.chooseADifferentLevel,
            onSecondaryPressed: () =>
                _handleOpenPicker(context, ref, state.chosenLevel),
          ),
        ),
      ),
    );
  }
}

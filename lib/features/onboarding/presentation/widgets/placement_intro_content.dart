import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/info_card.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/onboarding_config.dart';
import '../providers/onboarding_flow_provider.dart';
import 'benefit_chip_row.dart';
import 'step_title_block.dart';

/// Body content for the placement intro step:
/// title block with purple Pebbi mascot, two informative cards, and benefit chips.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// pure UI composition, accessible heading semantics, dynamic ICU subtitle.
class PlacementIntroContent extends ConsumerWidget {
  const PlacementIntroContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingFlowProvider);
    final learnableLanguages = ref.watch(learnableLanguagesProvider);
    final targetLang = learnableLanguages.cast<dynamic>().firstWhere(
      (lang) => lang.code == onboardingState.targetLanguageCode,
      orElse: () => null,
    );
    final languageName = targetLang?.englishName ?? 'Spanish';
    final subtitle = AppStrings.placementIntroSubtitle(
      language: languageName,
      questionsCount: OnboardingConfig.placementQuestionsCount,
      minutes: OnboardingConfig.placementEstimatedMinutes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: StepTitleBlock(
            showMascot: true,
            mascotOutfit: PebbiOutfit.defaultPurple,
            mascotExpression: PebbiExpression.happy,
            title: AppStrings.placementIntroTitle,
            subtitle: subtitle,
          ),
        ),
        const InfoCard(
          title: AppStrings.placementCard1Title,
          body: AppStrings.placementCard1Body,
        ),
        const SizedBox(height: AppSpacing.md),
        const InfoCard(
          title: AppStrings.placementCard2Title,
          body: AppStrings.placementCard2Body,
        ),
        const SizedBox(height: AppSpacing.lg),
        const BenefitChipRow(),
      ],
    );
  }
}

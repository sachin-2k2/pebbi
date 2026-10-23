import 'package:flutter/material.dart';
import '../../../../../core/design_system/benefit_chip.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/mission_brief.dart';

/// Wrapping row of small tinted informative pill chips ("Bits").
///
/// Follows AGENTS.md §3 & §8:
/// - Reuses [BenefitChip] with semantic tones (peach, purple/lavender, mint, neutral)
/// - Target language name derived dynamically from language data
/// - Derived suggested replies indicator (on = mint, off = neutral)
class BriefInfoChips extends StatelessWidget {
  const BriefInfoChips({
    super.key,
    required this.brief,
    required this.targetLanguageName,
    required this.isSuggestedRepliesOn,
  });

  final MissionBrief brief;
  final String targetLanguageName;
  final bool isSuggestedRepliesOn;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        BenefitChip(
          label: AppStrings.missionDurationMinutesApprox(
            brief.estimatedMinutes,
          ),
          tone: ChipTone.peach,
          showDefaultIcon: false,
        ),
        BenefitChip(
          label: targetLanguageName,
          tone: ChipTone.purple,
          showDefaultIcon: false,
        ),
        BenefitChip(
          label: isSuggestedRepliesOn
              ? AppStrings.suggestedRepliesOn
              : AppStrings.suggestedRepliesOff,
          tone: isSuggestedRepliesOn ? ChipTone.mint : ChipTone.neutral,
          showDefaultIcon: false,
        ),
        if (brief.isCompleted)
          const BenefitChip(
            label: AppStrings.missionCompletedTag,
            tone: ChipTone.mint,
            icon: Icons.check_circle_rounded,
            showDefaultIcon: false,
          ),
        if (brief.isPremium)
          const BenefitChip(
            label: AppStrings.missionLockedTag,
            tone: ChipTone.neutral,
            icon: Icons.lock_rounded,
            showDefaultIcon: false,
          ),
      ],
    );
  }
}

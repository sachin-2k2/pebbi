import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/design_system/difficulty_pips.dart';
import '../../../../core/design_system/icon_tile.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/mission_summary.dart';

/// Right-hand preview pane for Expanded (Tablet/Desktop) TwoPaneLayout.
///
/// Follows AGENTS.md §4.3: Displays selected mission brief preview, or a prompt
/// if no scene has been selected yet.
class MissionPreviewPane extends StatelessWidget {
  const MissionPreviewPane({
    super.key,
    required this.selectedMission,
    required this.onStartMission,
  });

  final MissionSummary? selectedMission;
  final ValueChanged<MissionSummary> onStartMission;

  @override
  Widget build(BuildContext context) {
    if (selectedMission == null) {
      return Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.borderLight),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            PebbiMascot(
              size: 72.0,
              outfit: PebbiOutfit.backpack,
              expression: PebbiExpression.happy,
              accentColor: AppColors.brandPurple,
            ),
            SizedBox(height: AppSpacing.md),
            Text('Select a scene', style: AppTypography.cardTitle),
            SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.selectScenePrompt,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final mission = selectedMission!;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppSpacing.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile.emoji(
                mission.emoji,
                backgroundColor: AppColors.tintPeach,
                size: 52.0,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mission.title, style: AppTypography.screenTitle),
                    const SizedBox(height: 2.0),
                    Text(
                      '${mission.characterName}, ${mission.characterRole}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Difficulty: ',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              DifficultyPips(
                filledCount: mission.difficulty,
                totalCount: 3,
                filledColor: AppColors.coral,
                excludeSemantics: true,
              ),
              const Spacer(),
              Text(
                AppStrings.missionDurationMinutes(mission.durationMinutes),
                style: AppTypography.caption,
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          const Text(
            'Objectives & Rehearsal Brief',
            style: AppTypography.cardTitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Practice natural dialogue in real time. Pebbi will guide you through ordering, answering questions, and requesting specifics.',
            style: AppTypography.caption,
          ),
          const Spacer(),
          Button3D(
            label: AppStrings.startPractice,
            backgroundColor: AppColors.coralHeroCard,
            depthColor: AppColors.coralHeroCardDepth,
            onPressed: () => onStartMission(mission),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/design_system/difficulty_pips.dart';
import '../../../../core/design_system/icon_tile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/mission_summary.dart';
import 'mission_status_tag.dart';

/// Single mission row card tile.
///
/// Follows AGENTS.md §3 (under 150 lines), §4 (responsive), & accessibility:
/// - Peach tinted icon tile with emoji on the left.
/// - Bold title and muted character/duration line.
/// - Three coral difficulty pips with non-color contrast cues.
/// - Status tag on the trailing side.
/// - Single consolidated Semantics announcement for the whole row.
class MissionTile extends StatelessWidget {
  const MissionTile({
    super.key,
    required this.mission,
    required this.onTap,
    this.isPremiumLocked = false,
  });

  final MissionSummary mission;
  final VoidCallback onTap;
  final bool isPremiumLocked;

  @override
  Widget build(BuildContext context) {
    final statusText = isPremiumLocked
        ? AppStrings.missionTagPremium
        : (mission.status == MissionStatus.done
              ? AppStrings.missionTagDone
              : (mission.status == MissionStatus.inProgress
                    ? AppStrings.missionTagInProgress
                    : AppStrings.missionTagNew));

    final semanticsLabel = AppStrings.missionTileSemantics(
      title: mission.title,
      characterName: mission.characterName,
      characterRole: mission.characterRole,
      minutes: mission.durationMinutes,
      difficulty: mission.difficulty,
      totalDifficulty: 3,
      status: statusText,
      isLocked: isPremiumLocked,
    );

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: AppSpacing.cardShadow,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconTile.emoji(
                  mission.emoji,
                  backgroundColor: AppColors.tintPeach,
                  size: 48.0,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (MediaQuery.textScalerOf(context).scale(1.0) >
                          1.6) ...[
                        Text(
                          mission.title,
                          style: AppTypography.cardTitle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        MissionStatusTag(
                          status: mission.status,
                          isPremiumLocked: isPremiumLocked,
                        ),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                mission.title,
                                style: AppTypography.cardTitle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            MissionStatusTag(
                              status: mission.status,
                              isPremiumLocked: isPremiumLocked,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 3.0),
                      Text(
                        '${mission.characterName}, ${mission.characterRole} · ${AppStrings.missionDurationMinutes(mission.durationMinutes)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6.0),
                      DifficultyPips(
                        filledCount: mission.difficulty,
                        totalCount: 3,
                        filledColor: AppColors.coral,
                        pipWidth: 16.0,
                        pipHeight: 5.0,
                        excludeSemantics: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

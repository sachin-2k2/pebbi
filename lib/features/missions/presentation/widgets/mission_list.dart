import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/mission_access_rules.dart';
import '../../domain/mission_summary.dart';
import 'mission_tile.dart';

/// List of mission tiles with support for empty and loading skeleton states.
///
/// Follows AGENTS.md §3 (under 150 lines) and §4 (responsive).
class MissionList extends StatelessWidget {
  const MissionList({
    super.key,
    required this.missions,
    required this.onMissionTap,
    this.userProfile,
  });

  final List<MissionSummary> missions;
  final ValueChanged<MissionSummary> onMissionTap;
  final dynamic userProfile;

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PebbiMascot(
              size: 64.0,
              expression: PebbiExpression.surprised,
              accentColor: context.palette.brand,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.emptyMissionsTitle,
              style: AppTypography.cardTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.emptyMissionsSubtitle,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < missions.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: MissionTile(
              mission: missions[i],
              isPremiumLocked:
                  MissionAccessRules.missionAccess(userProfile, missions[i]) ==
                  MissionAccessResult.needsPremium,
              onTap: () => onMissionTap(missions[i]),
            ),
          ),
        ],
      ],
    );
  }
}

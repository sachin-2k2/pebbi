import 'package:flutter/material.dart';
import '../../../../../core/design_system/back_link.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Error placeholder displayed when a mission brief fails to load or cannot be found.
///
/// Follows AGENTS.md §3: Extracted widget keeping screen under 100 lines.
class MissionBriefErrorView extends StatelessWidget {
  const MissionBriefErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BackLink(label: AppStrings.missionsLink),
          const Spacer(),
          Text(AppStrings.missionNotFound, style: AppTypography.screenTitle),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.missionNotFoundSubtitle,
            style: AppTypography.bodyMedium,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/mission_summary.dart';

/// Tag pill displayed on the trailing side of a mission row.
///
/// Follows AGENTS.md §3 and WCAG AA contrast standards:
/// - "new": lavender tint with brand purple text (>5.0:1 contrast).
/// - "done": mint tint with deep emerald text and checkmark icon.
/// - "in progress": amber tint with dark amber text.
/// - "Premium": purple tint with lock icon for locked items.
class MissionStatusTag extends StatelessWidget {
  const MissionStatusTag({
    super.key,
    required this.status,
    this.isPremiumLocked = false,
  });

  final MissionStatus status;
  final bool isPremiumLocked;

  @override
  Widget build(BuildContext context) {
    if (isPremiumLocked) {
      return _buildTag(
        background: AppColors.chipPurpleBackground,
        foreground: AppColors.brandPurple,
        label: AppStrings.missionTagPremium,
        icon: Icons.lock_rounded,
      );
    }

    switch (status) {
      case MissionStatus.newMission:
        return _buildTag(
          background: AppColors.tintLavender,
          foreground: AppColors.brandPurple,
          label: AppStrings.missionTagNew,
        );
      case MissionStatus.done:
        return _buildTag(
          background: AppColors.tintMint,
          foreground: AppColors.mintDepth,
          label: AppStrings.missionTagDone,
          icon: Icons.check_rounded,
        );
      case MissionStatus.inProgress:
        return _buildTag(
          background: AppColors.chipAmberBackground,
          foreground: AppColors.chipAmberText,
          label: AppStrings.missionTagInProgress,
          icon: Icons.timelapse_rounded,
        );
    }
  }

  Widget _buildTag({
    required Color background,
    required Color foreground,
    required String label,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.0, color: foreground),
            const SizedBox(width: 4.0),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

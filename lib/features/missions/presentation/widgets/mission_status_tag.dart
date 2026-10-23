import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
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
    final palette = context.palette;

    if (isPremiumLocked) {
      return _buildTag(
        background: palette.tintLavender,
        foreground: palette.brandText,
        label: AppStrings.missionTagPremium,
        icon: Icons.lock_rounded,
      );
    }

    switch (status) {
      case MissionStatus.newMission:
        return _buildTag(
          background: palette.tintLavender,
          foreground: palette.brandText,
          label: AppStrings.missionTagNew,
        );
      case MissionStatus.done:
        return _buildTag(
          background: palette.tintMint,
          foreground: palette.successText,
          label: AppStrings.missionTagDone,
          icon: Icons.check_rounded,
        );
      case MissionStatus.inProgress:
        return _buildTag(
          background: palette.tintYellow,
          foreground: palette.warningText,
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
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

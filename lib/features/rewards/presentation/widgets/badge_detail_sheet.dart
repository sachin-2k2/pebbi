import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/layout/adaptive_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/badge_item.dart';
import '../../domain/badge_status.dart';
import 'badge_progress_bar.dart';

/// Bottom sheet displaying detailed requirements and progression for a badge.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.5.
class BadgeDetailSheet extends StatelessWidget {
  const BadgeDetailSheet({super.key, required this.badge});

  final BadgeItem badge;

  static Future<void> show(BuildContext context, BadgeItem badge) {
    return AdaptiveSheet.show<void>(
      context: context,
      builder: (sheetContext) => BadgeDetailSheet(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final bodyColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 48.0)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            badge.name,
            style: AppTypography.cardTitle.copyWith(
              color: titleColor,
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            badge.status == BadgeStatus.earned
                ? AppStrings.rewardsBadgeEarned
                : badge.howToEarn,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: bodyColor,
              fontSize: 14.0,
            ),
          ),
          if (badge.hasProgressBar) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              '${badge.currentProgress ?? 0} / ${badge.targetProgress}',
              style: AppTypography.caption.copyWith(
                color: bodyColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            BadgeProgressBar(progressRatio: badge.progressRatio),
          ],
          const SizedBox(height: AppSpacing.lg),
          Button3D.secondary(
            label: AppStrings.rewardsBadgeDetailClose,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

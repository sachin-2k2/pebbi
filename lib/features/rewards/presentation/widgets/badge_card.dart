import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/badge_item.dart';
import '../../domain/badge_status.dart';
import 'badge_progress_bar.dart';

/// Individual badge card displaying emoji, title, locked/earned state, and progress.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.6.
class BadgeCard extends StatelessWidget {
  const BadgeCard({super.key, required this.badge, required this.onTap});

  final BadgeItem badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final isEarned = badge.status == BadgeStatus.earned;

    final String semanticsLabel = switch (badge.status) {
      BadgeStatus.earned => AppStrings.rewardsBadgeSemanticsEarned(
        badge.name,
        null,
      ),
      BadgeStatus.inProgress => AppStrings.rewardsBadgeSemanticsInProgress(
        badge.name,
        badge.currentProgress ?? 0,
        badge.targetProgress ?? 0,
      ),
      BadgeStatus.locked => AppStrings.rewardsBadgeSemanticsLocked(
        badge.name,
        badge.howToEarn,
      ),
    };

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs + 2.0,
            vertical: AppSpacing.sm + 2.0,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: border, width: 1.0),
            boxShadow: isDark ? null : AppSpacing.cardShadow,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: SizedBox(
              width: 110.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: isEarned ? 1.0 : 0.35,
                    child: Text(
                      badge.emoji,
                      style: const TextStyle(fontSize: 28.0),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    badge.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.cardTitle.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEarned
                            ? Icons.check_circle_rounded
                            : Icons.lock_outline_rounded,
                        size: 11.5,
                        color: isEarned ? AppColors.accentMint : mutedColor,
                      ),
                      const SizedBox(width: 3.0),
                      Flexible(
                        child: Text(
                          isEarned
                              ? AppStrings.rewardsBadgeEarned
                              : AppStrings.rewardsBadgeLocked,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: isEarned ? AppColors.accentMint : mutedColor,
                            fontSize: 11.0,
                            fontWeight:
                                isEarned ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (badge.hasProgressBar)
                    BadgeProgressBar(progressRatio: badge.progressRatio),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

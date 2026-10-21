import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/badge_item.dart';
import 'badge_detail_sheet.dart';
import 'badge_grid.dart';
import 'earned_count_pill.dart';

/// Section displaying the "Badges" title, earned count pill, and responsive grid.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.1.
class BadgesSection extends StatelessWidget {
  const BadgesSection({
    super.key,
    required this.badges,
    required this.earnedCount,
  });

  final List<BadgeItem> badges;
  final int earnedCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            Text(
              AppStrings.rewardsBadgesTitle,
              style: AppTypography.cardTitle.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w800,
                fontSize: 18.0,
              ),
            ),
            EarnedCountPill(count: earnedCount),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        BadgeGrid(
          badges: badges,
          onBadgeTap: (badge) => BadgeDetailSheet.show(context, badge),
        ),
      ],
    );
  }
}

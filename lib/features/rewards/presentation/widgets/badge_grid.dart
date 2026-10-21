import 'package:flutter/widgets.dart';
import '../../../../core/layout/responsive_grid.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/badge_item.dart';
import 'badge_card.dart';

/// Responsive 3-to-4 column grid of achievement badge cards.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.1 (adapts on large text).
class BadgeGrid extends StatelessWidget {
  const BadgeGrid({super.key, required this.badges, required this.onBadgeTap});

  final List<BadgeItem> badges;
  final ValueChanged<BadgeItem> onBadgeTap;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final maxItemWidth = textScale > 1.25 ? 180.0 : 125.0;
    final childAspectRatio = textScale >= 1.8
        ? 0.65
        : (textScale >= 1.3 ? 0.72 : (textScale > 1.05 ? 0.80 : 0.88));

    return ResponsiveGrid(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      maxItemWidth: maxItemWidth,
      mainAxisSpacing: AppSpacing.sm + 2.0,
      crossAxisSpacing: AppSpacing.sm + 2.0,
      childAspectRatio: childAspectRatio,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return BadgeCard(badge: badge, onTap: () => onBadgeTap(badge));
      },
    );
  }
}

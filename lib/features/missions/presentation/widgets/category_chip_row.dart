import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/mission_category.dart';
import 'category_chip.dart';

/// Horizontally scrollable row of category filter chips without visible scrollbars.
///
/// Follows AGENTS.md §3 (under 150 lines) and accessibility guidelines:
/// - Hidden scrollbars per design spec.
/// - Announces count updates via live region on filter change.
class CategoryChipRow extends StatelessWidget {
  const CategoryChipRow({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.matchingMissionsCount,
  });

  final List<MissionCategory> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final int? matchingMissionsCount;

  void _handleSelect(BuildContext context, String id) {
    onCategorySelected(id);
    if (matchingMissionsCount != null) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        AppStrings.categoryFilterLiveAnnouncement(matchingMissionsCount!),
        TextDirection.ltr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            for (int i = 0; i < categories.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              CategoryChip(
                category: categories[i],
                isSelected: categories[i].id == selectedCategoryId,
                onTap: () => _handleSelect(context, categories[i].id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

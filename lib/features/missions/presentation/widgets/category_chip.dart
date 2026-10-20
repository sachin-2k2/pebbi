import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/mission_category.dart';

/// Single category filter chip pill.
///
/// Follows AGENTS.md §3 (under 150 lines) and §8:
/// - Selected: lavender fill, brand purple border, bold purple text.
/// - Unselected: white surface, light border, muted text.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final MissionCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? AppColors.tintLavender : AppColors.surface;
    final border = isSelected ? AppColors.brandPurple : AppColors.borderLight;
    final fg = isSelected ? AppColors.brandPurple : AppColors.textMuted;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${category.title}, ${isSelected ? 'selected' : 'not selected'}',
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Container(
            constraints: const BoxConstraints(minHeight: 40.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: border, width: isSelected ? 1.5 : 1.0),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (category.emoji.isNotEmpty) ...[
                  Text(category.emoji, style: const TextStyle(fontSize: 14.0)),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  category.title,
                  style: AppTypography.labelMedium.copyWith(
                    color: fg,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

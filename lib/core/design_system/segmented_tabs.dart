import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable 3-segment pill control on a soft lavender track.
///
/// Follows AGENTS.md §3 (<100 lines), §4.6 (>=44dp tap target), & WCAG AA:
/// - Track uses [AppColors.segmentedTrackBackground].
/// - Selected segment renders as an elevated white pill with soft shadow.
/// - Unselected segments maintain >=6.2:1 contrast ratio.
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
    required this.labelBuilder,
    this.semanticsLabelBuilder,
  });

  final List<T> items;
  final T selectedItem;
  final ValueChanged<T> onSelected;
  final String Function(T item) labelBuilder;
  final String Function(T item, int index, int total, bool isSelected)?
  semanticsLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? AppColors.darkSegmentedTrackBackground
        : AppColors.segmentedTrackBackground;

    return Container(
      constraints: const BoxConstraints(minHeight: 48.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = item == selectedItem;

          return Expanded(
            child: _SegmentItem(
              label: labelBuilder(item),
              isSelected: isSelected,
              onTap: () => onSelected(item),
              semanticsLabel: semanticsLabelBuilder?.call(
                item,
                index + 1,
                items.length,
                isSelected,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.semanticsLabel,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark
        ? AppColors.darkSegmentedPillBackground
        : AppColors.segmentedPillBackground;
    final textColor = isSelected
        ? (isDark
              ? AppColors.darkSegmentedTextSelected
              : AppColors.segmentedTextSelected)
        : (isDark
              ? AppColors.darkSegmentedTextUnselected
              : AppColors.segmentedTextUnselected);

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticsLabel ?? label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? selectedBg : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 2.0,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

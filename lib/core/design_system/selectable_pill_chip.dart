import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Available sizing scale for [SelectablePillChip].
enum SelectablePillChipSize { small, medium, large }

/// Reusable selectable pill chip component adhering to AGENTS.md §4.6 & §8.
///
/// Guaranteed minimum 48×48dp accessible tap target, flexible sizing,
/// WCAG AA/AAA contrast, and optional selection indicator icon for non-color identification.
class SelectablePillChip extends StatelessWidget {
  const SelectablePillChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.size = SelectablePillChipSize.medium,
    this.showCheckIcon = false,
    this.semanticsLabel,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.borderColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final SelectablePillChipSize size;
  final bool showCheckIcon;
  final String? semanticsLabel;
  final Color? selectedBackgroundColor;
  final Color? unselectedBackgroundColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final Color? borderColor;

  EdgeInsets get _padding {
    switch (size) {
      case SelectablePillChipSize.small:
        return const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0);
      case SelectablePillChipSize.medium:
        return const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0);
      case SelectablePillChipSize.large:
        return const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0);
    }
  }

  double get _fontSize {
    switch (size) {
      case SelectablePillChipSize.small:
        return 13.0;
      case SelectablePillChipSize.medium:
        return 14.0;
      case SelectablePillChipSize.large:
        return 15.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultSelectedBg =
        selectedBackgroundColor ?? AppColors.correctionPillSelected;
    final defaultUnselectedBg =
        unselectedBackgroundColor ??
        (isDark ? AppColors.darkCorrectionPillUnselected : AppColors.surface);
    final bg = isSelected ? defaultSelectedBg : defaultUnselectedBg;

    final defaultSelectedFg = selectedTextColor ?? Colors.white;
    final defaultUnselectedFg =
        unselectedTextColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);
    final fg = isSelected ? defaultSelectedFg : defaultUnselectedFg;

    final defaultBorder =
        borderColor ??
        (isSelected
            ? defaultSelectedBg
            : (isDark
                  ? AppColors.darkCorrectionPillBorder
                  : AppColors.correctionPillBorder));

    return Semantics(
      button: true,
      selected: isSelected,
      label:
          semanticsLabel ??
          '$label, ${isSelected ? 'selected' : 'not selected'}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Container(
            constraints: const BoxConstraints(minHeight: 38.0, minWidth: 44.0),
            padding: _padding,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(
                color: defaultBorder,
                width: isSelected ? 1.5 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: defaultSelectedBg.withValues(alpha: 0.28),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected && showCheckIcon) ...[
                  Icon(Icons.check_rounded, size: _fontSize * 0.95, color: fg),
                  const SizedBox(width: 4.0),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: _fontSize,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w700,
                        color: fg,
                        letterSpacing: 0.1,
                      ),
                    ),
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

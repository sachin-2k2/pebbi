import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Circular accent colour swatch with idle and selected states.
///
/// Follows AGENTS.md §3 & §4: reusable design system component,
/// minimum 48dp tap target, high-contrast outer ring with gap for selected state,
/// accessible semantics (announces option name, index, and selected state).
class AccentSwatch extends StatelessWidget {
  const AccentSwatch({
    super.key,
    required this.color,
    required this.name,
    required this.isSelected,
    required this.onTap,
    required this.index,
    required this.total,
  });

  final Color color;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final gapColor = isDark ? AppColors.darkBackground : AppColors.background;

    final semanticsLabel =
        '$name, option $index of $total${isSelected ? ', selected' : ''}';

    return Semantics(
      button: true,
      label: semanticsLabel,
      selected: isSelected,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: SizedBox(
            width: AppSpacing.minTouchTarget,
            height: AppSpacing.minTouchTarget,
            child: Center(
              child: SizedBox(
                width: 44.0,
                height: 44.0,
                child: isSelected
                    ? Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ringColor, width: 2.5),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: gapColor,
                          ),
                          padding: const EdgeInsets.all(1.5),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Container(
                          width: 38.0,
                          height: 38.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
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

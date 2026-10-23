import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Single-choice selectable option pill with icons, disabled states, and 48dp minimum tap target.
///
/// Follows AGENTS.md §3, §4.6 & §8:
/// - Solid purple when selected, light neutral when unselected
/// - Clear disabled state with reason announcement
/// - Minimum 48dp tap target for accessibility
class OptionPill extends StatelessWidget {
  const OptionPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.isDisabled = false,
    this.disabledReason,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isDisabled;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final Color bg;
    final Color fg;
    final Color borderColor;

    if (isDisabled) {
      bg = palette.disabledFill;
      fg = palette.disabledText;
      borderColor = palette.disabledDepth;
    } else if (isSelected) {
      bg = palette.brand;
      fg = palette.textOnBrand;
      borderColor = palette.brand;
    } else {
      bg = palette.isDark ? palette.surfaceVariant : palette.surface;
      fg = palette.textPrimary;
      borderColor = palette.outline;
    }

    final semanticsLabel = isDisabled
        ? '$label, unavailable: ${disabledReason ?? ''}'
        : '$label, ${isSelected ? 'selected' : 'not selected'}';

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: !isDisabled,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md + 2.0,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: isSelected && !isDisabled
                  ? [
                      BoxShadow(
                        color: palette.brand.withValues(alpha: 0.28),
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
                if (icon != null) ...[
                  Icon(icon, size: 18.0, color: fg),
                  const SizedBox(width: AppSpacing.xs + 2.0),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w700,
                      color: fg,
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

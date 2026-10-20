import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/sticker_option.dart';

/// Selectable white starter sticker card with idle and selected states.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// min 48dp tap target, lavender fill + purple border for selected state,
/// accessible semantics hiding raw emoji and announcing label and state.
class StickerCard extends StatelessWidget {
  const StickerCard({
    super.key,
    required this.sticker,
    required this.isSelected,
    required this.onTap,
    required this.index,
    required this.total,
  });

  final StickerOption sticker;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isSelected
        ? (isDark ? AppColors.darkSurfaceVariant : AppColors.tintLavender)
        : (isDark ? AppColors.darkSurface : AppColors.surface);

    final borderColor = isSelected
        ? AppColors.brandPurple
        : (isDark ? AppColors.darkBorder : AppColors.borderLight);

    final borderWidth = isSelected ? 2.0 : 1.0;

    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    final semanticsLabel =
        '${sticker.title}, option $index of $total${isSelected ? ', selected' : ''}';

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 90.0,
              minWidth: AppSpacing.minTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: isDark || isSelected ? null : AppSpacing.cardShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(sticker.emoji, style: const TextStyle(fontSize: 28.0)),
                const SizedBox(height: AppSpacing.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    sticker.title,
                    textAlign: TextAlign.center,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 13.5,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w700,
                      color: titleColor,
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

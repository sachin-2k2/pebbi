import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/picture_option.dart';

/// Interactive rounded picture card in the 2x2 exercise grid.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// handles states (idle, selected, removedByHint, locked) and accessible semantics.
class PictureOptionCard extends StatelessWidget {
  const PictureOptionCard({
    super.key,
    required this.option,
    required this.index,
    required this.total,
    required this.isSelected,
    required this.isRemoved,
    required this.isLocked,
    required this.onTap,
  });

  final PictureOption option;
  final int index;
  final int total;
  final bool isSelected;
  final bool isRemoved;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isRemoved) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isSelected
        ? (isDark ? AppColors.darkSurfaceVariant : AppColors.tintLavender)
        : (isDark ? AppColors.darkSurface : AppColors.surface);

    final borderColor = isSelected
        ? AppColors.brandPurple
        : (isDark ? AppColors.darkBorder : AppColors.borderLight);

    final borderWidth = isSelected ? 2.5 : 1.5;

    return Semantics(
      button: !isLocked,
      selected: isSelected,
      label: AppStrings.pictureOptionSemantics(
        index: index,
        total: total,
        label: option.spokenLabel,
        isSelected: isSelected,
      ),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        elevation: isDark || isSelected ? 0 : 2,
        shadowColor: const Color(0x0F1E1647),
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  option.imageRef,
                  style: const TextStyle(fontSize: 48.0, height: 1.1),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

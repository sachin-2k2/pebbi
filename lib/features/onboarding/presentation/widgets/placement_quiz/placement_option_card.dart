import 'package:flutter/material.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/core/theme/app_spacing.dart';
import 'package:peddi/core/theme/app_typography.dart';
import 'package:peddi/features/onboarding/domain/placement_question.dart';

/// Interactive option tile displaying an emoji choice with accessible labeling.
///
/// Follows AGENTS.md §3 & §4.6: minimum 48dp target, size from constraints, under 100 lines.
class PlacementOptionCard extends StatelessWidget {
  const PlacementOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.isAnswered,
    required this.onTap,
  });

  final PlacementOption option;
  final bool isSelected;
  final bool isAnswered;
  final VoidCallback onTap;

  Color _backgroundColor(BuildContext context) {
    if (!isAnswered) {
      return isSelected
          ? AppColors.brandPurple.withValues(alpha: 0.1)
          : Theme.of(context).cardColor;
    }
    if (isSelected) {
      return option.isCorrect
          ? AppColors.mint.withValues(alpha: 0.15)
          : AppColors.coral.withValues(alpha: 0.15);
    }
    if (option.isCorrect) {
      return AppColors.mint.withValues(alpha: 0.08);
    }
    return Theme.of(context).cardColor;
  }

  Border _border() {
    if (!isAnswered) {
      return Border.all(
        color: isSelected ? AppColors.brandPurple : AppColors.borderLight,
        width: isSelected ? 2.0 : 1.0,
      );
    }
    if (isSelected) {
      return Border.all(
        color: option.isCorrect ? AppColors.mint : AppColors.coral,
        width: 2.5,
      );
    }
    if (option.isCorrect) {
      return Border.all(color: AppColors.mint, width: 1.5);
    }
    return Border.all(
      color: AppColors.borderLight.withValues(alpha: 0.5),
      width: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: option.label,
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAnswered ? null : onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            constraints: const BoxConstraints(minHeight: 88.0, minWidth: 88.0),
            decoration: BoxDecoration(
              color: _backgroundColor(context),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: _border(),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.brandPurple.withValues(alpha: 0.1),
                        blurRadius: 8.0,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  option.emoji,
                  style: const TextStyle(fontSize: 36.0),
                  textAlign: TextAlign.center,
                ),
                if (option.label.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    option.label,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

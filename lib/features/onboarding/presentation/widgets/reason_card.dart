import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/learning_reason.dart';
import 'reason_icon.dart';

/// Card widget representing a learning reason option in Step 5.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// min 48dp tap target, accessible semantics, theme tokens.
class ReasonCard extends StatelessWidget {
  const ReasonCard({
    super.key,
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  final LearningReason reason;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppColors.tintLavender : AppColors.surface;
    final borderColor = isSelected
        ? AppColors.brandPurple
        : AppColors.borderLight;
    final borderWidth = isSelected ? 1.5 : 1.0;
    const textColor = AppColors.textPrimary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: AppStrings.reasonCardSemantics(reason.label, isSelected),
      excludeSemantics: true,
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56.0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ReasonIcon(emoji: reason.iconEmoji),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    reason.label,
                    style: AppTypography.screenTitle.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.25,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.check,
                    size: 18.0,
                    color: AppColors.brandPurple,
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

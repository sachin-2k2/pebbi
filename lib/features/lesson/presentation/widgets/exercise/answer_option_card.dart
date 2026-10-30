import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/text_option.dart';
import 'number_badge.dart';

/// Full-width rounded card for text answer choices.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// 48dp min touch target, accessible single-choice semantics, wraps cleanly at 200% text.
class AnswerOptionCard extends StatelessWidget {
  const AnswerOptionCard({
    super.key,
    required this.option,
    required this.number,
    required this.totalCount,
    required this.isSelected,
    this.isCorrectAnswer = false,
    this.isWrongAnswer = false,
    required this.isRemoved,
    required this.isLocked,
    required this.onTap,
  });

  final TextOption option;
  final int number;
  final int totalCount;
  final bool isSelected;
  final bool isCorrectAnswer;
  final bool isWrongAnswer;
  final bool isRemoved;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bg;
    final Color borderColor;
    final double borderWidth;

    if (isCorrectAnswer) {
      bg = isDark ? const Color(0xFF132B20) : AppColors.successSurface;
      borderColor = AppColors.successBorder;
      borderWidth = 2.5;
    } else if (isWrongAnswer) {
      bg = isDark ? const Color(0xFF2E1515) : AppColors.errorSurface;
      borderColor = AppColors.errorBorder;
      borderWidth = 2.5;
    } else if (isSelected) {
      bg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF5F3FF);
      borderColor = AppColors.brandPurple;
      borderWidth = 2.5;
    } else {
      bg = isDark ? AppColors.darkSurface : AppColors.surface;
      borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;
      borderWidth = 1.5;
    }

    Widget? statusIcon;
    if (isCorrectAnswer) {
      statusIcon = const Icon(
        Icons.check_circle_rounded,
        color: AppColors.successTextHeader,
        size: 22,
      );
    } else if (isWrongAnswer) {
      statusIcon = const Icon(
        Icons.cancel_rounded,
        color: AppColors.errorTextHeader,
        size: 22,
      );
    }

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: !isRemoved && !isLocked,
      label: AppStrings.textOptionSemantics(
        index: number,
        total: totalCount,
        text: option.text,
        isSelected: isSelected,
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isRemoved ? 0.15 : 1.0,
        child: IgnorePointer(
          ignoring: isRemoved || isLocked,
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: AppSpacing.buttonHeightLg,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md + 2.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    NumberBadge(number: number, isSelected: isSelected),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        option.text,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (statusIcon != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      statusIcon,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Large rounded tappable field displaying the selected birth year with dropdown chevron.
///
/// Follows AGENTS.md §3 and §4: under 100 lines, min 48dp tap target,
/// semantic label, responsive container.
class YearOfBirthField extends StatelessWidget {
  const YearOfBirthField({super.key, required this.year, required this.onTap});

  final int? year;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayText = year != null ? year.toString() : '----';
    final semanticsLabel = year != null
        ? AppStrings.yearFieldSemantics(year!)
        : AppStrings.yearPickerTitle;

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 58.0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayText,
                  style: AppTypography.screenTitle.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textPrimary,
                  size: 24.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

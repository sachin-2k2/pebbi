import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Accessible compact pill action button with guaranteed 48dp minimum tap target.
///
/// Follows AGENTS.md §4.6 & WCAG AA/AAA: 7.5:1 contrast, 48dp touch area.
class SettingsActionPill extends StatelessWidget {
  const SettingsActionPill({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkPracticeLavenderBackground
        : AppColors.tintLavender;
    final textColor = isDark
        ? AppColors.darkPracticeLavenderIcon
        : AppColors.brandPurple;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 8.0,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

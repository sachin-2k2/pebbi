import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/reminder_time.dart';

/// Card displaying the reminder time setting with a tappable time-picker button.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// min 48dp tap target, device 12h/24h format support, accessible semantics.
class ReminderTimeCard extends StatelessWidget {
  const ReminderTimeCard({
    super.key,
    required this.reminderTime,
    required this.onTap,
  });

  final ReminderTime reminderTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final pillBg = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.tintLavender;
    final is24Hour = MediaQuery.alwaysUse24HourFormatOf(context);
    final displayTime = reminderTime.formatDisplay(alwaysUse24Hour: is24Hour);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border, width: 1.0),
        boxShadow: isDark ? null : AppSpacing.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.brandPurple,
                  size: 22.0,
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppStrings.reminderTimeLabel,
                      style: AppTypography.cardTitle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            flex: 2,
            child: _buildTimePill(displayTime, titleColor, pillBg),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePill(String displayTime, Color titleColor, Color pillBg) {
    return Semantics(
      button: true,
      label: AppStrings.reminderTimeSemantics(displayTime),
      excludeSemantics: true,
      child: Material(
        color: pillBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTime,
                      style: AppTypography.screenTitle.copyWith(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16.0,
                      color: AppColors.textMuted,
                    ),
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

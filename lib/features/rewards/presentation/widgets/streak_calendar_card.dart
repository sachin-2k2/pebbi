import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/calendar_day.dart';
import 'calendar_caption.dart';
import 'streak_calendar.dart';

/// Card container hosting the rolling 28-day calendar and repair footnote.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.1.
class StreakCalendarCard extends StatelessWidget {
  const StreakCalendarCard({
    super.key,
    required this.days,
    required this.activeDaysCount,
  });

  final List<CalendarDay> days;
  final int activeDaysCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border, width: 1.0),
        boxShadow: isDark ? null : AppSpacing.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.rewardsLast4WeeksTitle,
            style: AppTypography.cardTitle.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w800,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          StreakCalendar(days: days, activeDaysCount: activeDaysCount),
          const SizedBox(height: AppSpacing.md),
          const CalendarCaption(),
        ],
      ),
    );
  }
}

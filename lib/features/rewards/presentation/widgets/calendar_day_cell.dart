import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/calendar_day.dart';
import '../../domain/calendar_day_state.dart';

/// Single cell in the 28-day rolling streak calendar.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.1.
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({super.key, required this.day});

  final CalendarDay day;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Widget content;
    String stateDescription;

    switch (day.state) {
      case CalendarDayState.active:
        bg = isDark
            ? AppColors.darkCalendarCellActive
            : AppColors.calendarCellActive;
        content = Icon(
          Icons.local_fire_department_rounded,
          size: 18.0,
          color: isDark
              ? AppColors.darkCalendarCellActiveIcon
              : AppColors.calendarCellActiveIcon,
        );
        stateDescription = 'active';
        break;

      case CalendarDayState.freezeUsed:
        bg = isDark
            ? AppColors.darkCalendarCellFreeze
            : AppColors.calendarCellFreeze;
        content = Icon(
          Icons.ac_unit_rounded,
          size: 16.0,
          color: isDark
              ? AppColors.darkCalendarCellFreezeIcon
              : AppColors.calendarCellFreezeIcon,
        );
        stateDescription = 'freeze used';
        break;

      case CalendarDayState.repaired:
        bg = isDark
            ? AppColors.darkCalendarCellRepaired
            : AppColors.calendarCellRepaired;
        content = Icon(
          Icons.local_fire_department_rounded,
          size: 18.0,
          color: isDark
              ? AppColors.darkCalendarCellRepairedIcon
              : AppColors.calendarCellRepairedIcon,
        );
        stateDescription = 'repaired';
        break;

      case CalendarDayState.none:
        bg = isDark
            ? AppColors.darkCalendarCellInactive
            : AppColors.calendarCellInactive;
        final textColor = isDark
            ? AppColors.darkCalendarCellInactiveText
            : AppColors.calendarCellInactiveText;
        content = Text(
          '${day.dayNumber}',
          style: TextStyle(
            color: textColor,
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
          ),
        );
        stateDescription = 'inactive';
        break;
    }

    final todayBorder = day.isToday
        ? Border.all(
            color: isDark
                ? AppColors.darkCalendarTodayBorder
                : AppColors.calendarTodayBorder,
            width: 2.0,
          )
        : null;

    return Semantics(
      label: '${day.dayNumber}, $stateDescription',
      child: Container(
        height: 38.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10.0),
          border: todayBorder,
        ),
        child: content,
      ),
    );
  }
}

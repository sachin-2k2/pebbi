import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/calendar_day.dart';
import 'calendar_day_cell.dart';

/// 4x7 calendar grid of 28 rolling days ending today.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.1.
class StreakCalendar extends StatelessWidget {
  const StreakCalendar({
    super.key,
    required this.days,
    required this.activeDaysCount,
  });

  final List<CalendarDay> days;
  final int activeDaysCount;

  @override
  Widget build(BuildContext context) {
    // 28 days mapped to 4 rows of 7 columns
    final rows = <Widget>[];
    for (int r = 0; r < 4; r++) {
      final startIndex = r * 7;
      final rowDays = days.sublist(
        startIndex,
        (startIndex + 7).clamp(0, days.length),
      );

      rows.add(
        Row(
          children: [
            for (int c = 0; c < rowDays.length; c++) ...[
              if (c > 0) const SizedBox(width: AppSpacing.xs),
              Expanded(child: CalendarDayCell(day: rowDays[c])),
            ],
          ],
        ),
      );
      if (r < 3) {
        rows.add(const SizedBox(height: AppSpacing.xs + 2.0));
      }
    }

    return Semantics(
      label: AppStrings.rewardsCalendarSemantics(activeDaysCount),
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: rows,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/weekday.dart';
import 'weekday_chip.dart';

/// Responsive row of 7 weekday chips (M, T, W, T, F, S, S) from Monday to Sunday.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, equal-width flex distribution
/// ensuring zero horizontal overflow on small 360dp viewports.
class WeekdayChipsRow extends StatelessWidget {
  const WeekdayChipsRow({
    super.key,
    required this.selectedDayNumbers,
    required this.onToggleDay,
    this.spacing = AppSpacing.xs,
  });

  final Set<int> selectedDayNumbers;
  final ValueChanged<int> onToggleDay;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    const days = Weekday.allDays;

    return Row(
      children: [
        for (var i = 0; i < days.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(
            child: WeekdayChip(
              weekday: days[i],
              isSelected: selectedDayNumbers.contains(days[i].isoNumber),
              onTap: () => onToggleDay(days[i].isoNumber),
            ),
          ),
        ],
      ],
    );
  }
}

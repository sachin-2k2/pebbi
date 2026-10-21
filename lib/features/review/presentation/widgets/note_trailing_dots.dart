import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Small trailing dots indicator (0 to 3) from the prototype design.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.6.
/// Hidden from screen readers. Marked TODO(question).
class NoteTrailingDots extends StatelessWidget {
  const NoteTrailingDots({super.key, this.dots = 3});

  final int? dots;

  @override
  Widget build(BuildContext context) {
    final dotCount = dots ?? 0;
    if (dotCount <= 0) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isDark ? AppColors.darkNoteDots : AppColors.noteDots;

    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < dotCount.clamp(1, 3); i++) ...[
            if (i > 0) const SizedBox(width: 3.5),
            Container(
              width: 5.5,
              height: 5.5,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

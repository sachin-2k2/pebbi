import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';

/// Small decorative unchecked circle displayed to the left of each mission goal.
///
/// Follows AGENTS.md §3 & §8:
/// - Purely visual, excluded from screen-reader semantics (parent GoalRow provides full semantics).
/// - 22dp diameter with subtle circular outline.
class GoalCircle extends StatelessWidget {
  const GoalCircle({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ExcludeSemantics(
      child: Container(
        width: 22.0,
        height: 22.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: palette.outline, width: 2.0),
          color: Colors.transparent,
        ),
      ),
    );
  }
}

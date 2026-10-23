import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../l10n/app_strings.dart';

/// Full-width lavender 3D secondary button for reading mission goals aloud sequentially.
///
/// Follows AGENTS.md §3 & §8:
/// - Reuses [Button3D.secondary] with lavender face and deep purple text
/// - Dynamic label & icon toggling between "Hear the goal out loud" and "Stop"
/// - Explicit tap plays even when ambient sound setting is off (accessibility aid)
class HearGoalsButton extends StatelessWidget {
  const HearGoalsButton({
    super.key,
    required this.onPressed,
    this.isPlaying = false,
  });

  final VoidCallback onPressed;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = isPlaying
        ? AppStrings.stopGoalPlayback
        : AppStrings.hearGoalOutLoud;

    return Button3D.secondary(
      label: label,
      onPressed: onPressed,
      icon: Icon(
        isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
        size: 20.0,
        color: palette.brandText,
      ),
    );
  }
}

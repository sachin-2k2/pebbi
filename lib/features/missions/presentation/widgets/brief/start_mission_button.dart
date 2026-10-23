import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../l10n/app_strings.dart';

/// Full-width tactile mint 3D button to initiate role-play session checks and launch.
///
/// Follows AGENTS.md §3 & §8:
/// - Mint face with darker mint depth
/// - Displays loading state while pre-flight checks execute and ignores duplicate taps
class StartMissionButton extends StatelessWidget {
  const StartMissionButton({
    super.key,
    required this.onPressed,
    this.isStarting = false,
    this.isCompleted = false,
  });

  final VoidCallback onPressed;
  final bool isStarting;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = isCompleted
        ? AppStrings.tryAgainMission
        : AppStrings.startMission;

    return Button3D(
      label: label,
      backgroundColor: palette.mint,
      depthColor: palette.mintDepth,
      textColor: palette.textOnBrand,
      onPressed: isStarting ? null : onPressed,
      icon: isStarting
          ? SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: palette.textOnBrand,
              ),
            )
          : null,
    );
  }
}

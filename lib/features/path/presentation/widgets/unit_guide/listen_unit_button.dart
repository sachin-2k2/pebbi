import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../l10n/app_strings.dart';

/// Full-width 3D primary button initiating sequential guidebook listening.
///
/// Follows AGENTS.md §3 & §8: under 100 lines, uses [Button3D] and palette tokens.
class ListenUnitButton extends StatelessWidget {
  const ListenUnitButton({
    super.key,
    required this.isPlaying,
    required this.phraseCount,
    required this.onPressed,
    this.isEnabled = true,
  });

  final bool isPlaying;
  final int phraseCount;
  final VoidCallback onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final label = isPlaying
        ? AppStrings.stopListening
        : AppStrings.listenToUnit;
    final iconData = isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded;

    return Semantics(
      button: true,
      label: isPlaying
          ? AppStrings.stopListening
          : AppStrings.listenButtonSemantics(phraseCount),
      child: Button3D(
        label: label,
        onPressed: isEnabled ? onPressed : null,
        backgroundColor: palette.brand,
        depthColor: palette.brandDepth,
        textColor: palette.textOnBrand,
        icon: Icon(iconData, color: palette.textOnBrand, size: 20.0),
      ),
    );
  }
}

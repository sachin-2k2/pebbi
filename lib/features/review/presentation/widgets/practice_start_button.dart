import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../l10n/app_strings.dart';

/// Compact purple 3D "Start" button displayed inside the 2-minute practice tile.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.6.
class PracticeStartButton extends StatelessWidget {
  const PracticeStartButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Button3D(
      label: AppStrings.practiceStartButton,
      isFullWidth: false,
      width: 76.0,
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      minHeight: 38.0,
      depth: 3.0,
      borderRadius: 14.0,
      onPressed: onPressed,
    );
  }
}

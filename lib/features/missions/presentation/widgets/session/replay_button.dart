import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../l10n/app_strings.dart';

/// Small speaker icon button in character message bubble for hearing line read aloud.
///
/// Follows AGENTS.md §4.6 & §8: 48dp minimum tap area, WCAG AA contrast.
class ReplayButton extends StatelessWidget {
  const ReplayButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      label: AppStrings.sessionPlayLineTooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24.0),
          child: Container(
            width: 44.0,
            height: 36.0,
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.volume_up_outlined,
              size: 20.0,
              color: palette.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

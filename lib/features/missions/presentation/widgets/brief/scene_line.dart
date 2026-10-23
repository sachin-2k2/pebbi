import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_typography.dart';

/// Scene context line (e.g. "A busy café, morning rush").
///
/// Follows AGENTS.md §3 & §7.3:
/// - Bold regular size text
/// - Cleanly renders nothing when scene line is omitted (no gap left behind)
class SceneLine extends StatelessWidget {
  const SceneLine({super.key, this.sceneLine});

  final String? sceneLine;

  @override
  Widget build(BuildContext context) {
    final text = sceneLine;
    if (text == null || text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final palette = context.palette;

    return Text(
      text,
      style: AppTypography.bodyLarge.copyWith(
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        height: 1.35,
      ),
    );
  }
}

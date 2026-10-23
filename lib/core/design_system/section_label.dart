import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

/// Reusable small uppercase section label for form steps, option groups, and lists.
///
/// Follows AGENTS.md §3 & §8:
/// - Uses semantic typography and palette tokens (zero raw colors)
/// - Works seamlessly across light and dark modes
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.caption.copyWith(
        fontSize: 12.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: context.palette.textMuted,
      ),
    );
  }
}

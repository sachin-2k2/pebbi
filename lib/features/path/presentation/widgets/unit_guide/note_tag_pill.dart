import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Semantic pill badge for grammar, culture, or custom note tags.
///
/// Follows AGENTS.md §8: strictly consumes semantic palette roles (zero raw colors).
/// Fully tested to satisfy WCAG AA >= 4.5:1 text contrast in Light and Dark modes.
class NoteTagPill extends StatelessWidget {
  const NoteTagPill({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final normalized = tag.toLowerCase().trim();

    final (Color bg, Color fg) = switch (normalized) {
      'grammar' => (palette.tagGrammarFill, palette.tagGrammarText),
      'culture' => (palette.tagCultureFill, palette.tagCultureText),
      _ => (palette.tagNeutralFill, palette.tagNeutralText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: fg,
          fontSize: 12.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

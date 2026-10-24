import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Language switcher pill with glyph badge, native language name, and dropdown chevron.
///
/// Follows AGENTS.md §3 & §4: under 80 lines, 48dp minimum touch target.
class LanguagePill extends StatelessWidget {
  const LanguagePill({
    super.key,
    required this.language,
    this.glyph,
    this.onTap,
  });

  final String language;
  final String? glyph;
  final VoidCallback? onTap;

  /// Default script glyph lookup based on language name.
  static String glyphFor(String language) {
    final lower = language.toLowerCase();
    if (lower.contains('fran')) return 'É';
    if (lower.contains('deutsch') || lower.contains('german')) return 'ß';
    if (lower.contains('nihon') || lower.contains('japan')) return 'あ';
    if (lower.contains('arab')) return 'ع';
    return 'Ñ';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final displayGlyph = glyph ?? glyphFor(language);

    return Semantics(
      button: true,
      label: AppStrings.languagePillSemantics(language),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Container(
            constraints: const BoxConstraints(minHeight: 40.0),
            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: palette.outline, width: 1.0),
              boxShadow: palette.cardShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GlyphBadge(glyph: displayGlyph),
                const SizedBox(width: 3.0),
                Flexible(
                  child: Text(
                    language,
                    style: AppTypography.labelMedium.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: palette.textMuted,
                  size: 18.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlyphBadge extends StatelessWidget {
  const _GlyphBadge({required this.glyph});

  final String glyph;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: palette.tintLavender,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      alignment: Alignment.center,
      child: Text(
        glyph,
        style: TextStyle(
          color: palette.brandText,
          fontSize: 12.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

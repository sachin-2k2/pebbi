import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
    this.glyph = 'Ñ',
    this.onTap,
  });

  final String language;
  final String glyph;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.languagePillSemantics(language),
      child: Material(
        color: AppColors.surface,
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
              border: Border.all(color: AppColors.borderLight, width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A1E1647),
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GlyphBadge(glyph: glyph),
                const SizedBox(width: 3.0),
                Flexible(
                  child: Text(
                    language,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2.0),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 18.0,
                  color: AppColors.textMuted,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
      decoration: BoxDecoration(
        color: AppColors.tintLavender,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Text(
        glyph,
        style: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w800,
          color: AppColors.brandPurple,
          height: 1.2,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/grammar_note_summary.dart';
import 'note_trailing_dots.dart';

/// Single interactive grammar and culture note card with emoji, title, clamped excerpt, and trailing dots.
///
/// Follows AGENTS.md §3 (<150 lines, build <50 lines) and §4.6.
class NoteTile extends StatelessWidget {
  const NoteTile({super.key, required this.note, required this.onTap});

  final GrammarNoteSummary note;
  final VoidCallback onTap;

  bool get _isRtl =>
      note.languageCode == 'ar' || note.languageCode.startsWith('ar-');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final excerptColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMutedDarker;

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final maxExcerptLines = textScale > 1.4 ? 3 : 2;

    return Semantics(
      button: true,
      label: AppStrings.noteTileSemantics(
        title: note.title,
        excerpt: note.excerpt,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            constraints: const BoxConstraints(minHeight: 76.0),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: border, width: 1.0),
              boxShadow: isDark ? null : AppSpacing.cardShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 44.0,
                    height: 44.0,
                    alignment: Alignment.center,
                    child: Text(
                      note.emoji,
                      style: const TextStyle(fontSize: 26.0),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        note.title,
                        textDirection: _isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        note.excerpt,
                        textDirection: _isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        maxLines: maxExcerptLines,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 13.5,
                          color: excerptColor,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                NoteTrailingDots(dots: note.dots),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

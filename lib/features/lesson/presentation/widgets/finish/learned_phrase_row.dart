import 'package:flutter/material.dart';
import '../../../../../core/design_system/icon_tile.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/lesson_completion.dart';

/// Single interactive row presenting one learned phrase with audio playback.
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 45 lines,
/// 48dp minimum tap target (whole row is the target).
class LearnedPhraseRow extends StatelessWidget {
  const LearnedPhraseRow({
    super.key,
    required this.phrase,
    required this.onTap,
    this.showHelperLine = false,
  });

  final LearnedPhrase phrase;
  final VoidCallback onTap;
  final bool showHelperLine;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowBg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF5F4FB);
    final phraseColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final meaningColor = isDark ? AppColors.darkTextMuted : const Color(0xFF524F6B);

    final semanticsLabel = AppStrings.phraseRowSemantics(
      phrase: phrase.text,
      meaning: phrase.meaning,
    );

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: rowBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconTile.emoji(
                    phrase.emoji,
                    size: 38.0,
                    fontSize: 20.0,
                    backgroundColor: isDark
                        ? AppColors.darkBorder
                        : AppColors.surface,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          phrase.text,
                          style: AppTypography.cardTitle.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16.0,
                            color: phraseColor,
                          ),
                          textDirection: phrase.isRtl
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                        ),
                        const SizedBox(height: 1.0),
                        Text(
                          phrase.meaning,
                          style: AppTypography.caption.copyWith(
                            color: meaningColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.0,
                          ),
                        ),
                        if (showHelperLine && phrase.helperLine != null) ...[
                          const SizedBox(height: 2.0),
                          Text(
                            phrase.helperLine!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.brandPurple,
                              fontSize: 11.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ExcludeSemantics(
                    child: Icon(
                      Icons.volume_up_rounded,
                      size: 20.0,
                      color: isDark
                          ? AppColors.brandPurpleLight
                          : AppColors.brandPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/design_system/dashed_border_box.dart';
import '../../../../core/design_system/difficulty_pips.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/learnable_language.dart';
import 'coming_soon_badge.dart';
import 'language_glyph.dart';
import 'learners_caption.dart';

/// Card representing a language available to learn or coming soon.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// accessible semantics, adapts dynamically to content height.
class LearnLanguageCard extends StatelessWidget {
  const LearnLanguageCard({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final LearnableLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAvailable = language.isAvailable;
    final compactLearners = LearnersCaption.formatCompact(
      language.learnersCount,
    );
    final learnersText = AppStrings.learnersCountFormatted(compactLearners);

    final semanticsLabel = isAvailable
        ? AppStrings.availableCardSemantics(
            nativeName: language.nativeName,
            englishName: language.englishName,
            difficulty: language.difficulty ?? 1,
            totalDifficulty: 3,
            learnersText: learnersText,
            isSelected: isSelected,
          )
        : AppStrings.comingSoonCardSemantics(language.englishName);

    final cardContent = _CardContent(
      language: language,
      isSelected: isSelected,
    );

    return Semantics(
      button: true,
      selected: isAvailable ? isSelected : null,
      enabled: isAvailable,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: isAvailable
              ? _buildSolidCard(cardContent)
              : DashedBorderBox(
                  borderRadius: AppSpacing.radiusCard,
                  color: AppColors.borderLight,
                  child: cardContent,
                ),
        ),
      ),
    );
  }

  Widget _buildSolidCard(Widget content) {
    final bgColor = isSelected ? AppColors.tintLavender : AppColors.surface;
    final borderColor = isSelected
        ? AppColors.brandPurple
        : AppColors.borderLight;
    final borderWidth = isSelected ? 1.5 : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: content,
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.language, required this.isSelected});

  final LearnableLanguage language;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isAvailable = language.isAvailable;
    final glyphColor = isSelected
        ? AppColors.brandPurple
        : isAvailable
        ? AppColors.textPrimary
        : AppColors.textMuted;
    final nameColor = isSelected
        ? AppColors.brandPurple
        : isAvailable
        ? AppColors.textPrimary
        : AppColors.textMuted;
    final englishColor = isAvailable
        ? AppColors.textMuted
        : AppColors.textTertiary;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LanguageGlyph(glyph: language.glyph, color: glyphColor),
              if (isSelected)
                const Icon(
                  Icons.check,
                  size: 20.0,
                  color: AppColors.brandPurple,
                )
              else
                const SizedBox(width: 20.0, height: 20.0),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                language.nativeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.screenTitle.copyWith(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w700,
                  color: nameColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                language.englishName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  fontSize: 12.5,
                  color: englishColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAvailable && language.difficulty != null)
                DifficultyPips(filledCount: language.difficulty!)
              else
                const ComingSoonBadge(),
              const SizedBox(height: AppSpacing.xs),
              LearnersCaption(
                count: language.learnersCount,
                color: englishColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

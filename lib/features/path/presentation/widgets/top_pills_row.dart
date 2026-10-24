import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import 'app_logo_tile.dart';
import 'language_pill.dart';
import 'profile_button.dart';
import 'stat_pill.dart';

/// Top pills row widget per design spec §5 and screenshot 1.
///
/// Features app logo tile, language pill, streak pill, stars pill, and profile button.
class TopPillsRow extends StatelessWidget {
  const TopPillsRow({
    super.key,
    required this.language,
    required this.streakCount,
    required this.starsCount,
    this.glyph,
    this.onLanguageTap,
    this.onStreakTap,
    this.onStarsTap,
    this.onProfileTap,
  });

  final String language;
  final int streakCount;
  final int starsCount;
  final String? glyph;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onStreakTap;
  final VoidCallback? onStarsTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogoTile(),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: LanguagePill(
                      language: language,
                      glyph: glyph ?? LanguagePill.glyphFor(language),
                      onTap: onLanguageTap,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatPill(
                icon: Icon(
                  Icons.local_fire_department_outlined,
                  color: palette.coral,
                  size: 18.0,
                ),
                value: streakCount,
                semanticsLabel: '$streakCount day streak',
                onTap: onStreakTap,
              ),
              const SizedBox(width: AppSpacing.sm),
              StatPill(
                icon: Icon(
                  Icons.star_outline_rounded,
                  color: palette.gold,
                  size: 18.0,
                ),
                value: starsCount,
                semanticsLabel: '$starsCount stars',
                onTap: onStarsTap,
              ),
              const SizedBox(width: AppSpacing.sm),
              ProfileButton(onTap: onProfileTap),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
    this.onLanguageTap,
    this.onStreakTap,
    this.onStarsTap,
    this.onProfileTap,
  });

  final String language;
  final int streakCount;
  final int starsCount;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onStreakTap;
  final VoidCallback? onStarsTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppLogoTile(),
          const SizedBox(width: 4.0),
          Flexible(
            child: LanguagePill(language: language, onTap: onLanguageTap),
          ),
          const SizedBox(width: 4.0),
          StatPill(
            icon: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.streakOrange,
              size: 18.0,
            ),
            value: streakCount,
            semanticsLabel: '$streakCount day streak',
            onTap: onStreakTap,
          ),
          const SizedBox(width: 4.0),
          StatPill(
            icon: const Icon(
              Icons.star_rounded,
              color: AppColors.starGold,
              size: 18.0,
            ),
            value: starsCount,
            semanticsLabel: '$starsCount stars',
            onTap: onStarsTap,
          ),
          const SizedBox(width: 4.0),
          ProfileButton(onTap: onProfileTap),
        ],
      ),
    );
  }
}

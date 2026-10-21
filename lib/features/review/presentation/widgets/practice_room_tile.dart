import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/practice_room.dart';
import '../../domain/practice_room_tone.dart';
import 'practice_start_button.dart';

/// Single interactive practice room card with tinted icon tile, title, subtitle, and optional CTA.
///
/// Follows AGENTS.md §3 (<150 lines, build <50 lines) and §4.6.
class PracticeRoomTile extends StatelessWidget {
  const PracticeRoomTile({
    super.key,
    required this.room,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final PracticeRoom room;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  (Color bg, Color iconColor, IconData icon) _toneStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (room.tone) {
      case PracticeRoomTone.lavender:
        return (
          isDark
              ? AppColors.darkPracticeLavenderBackground
              : AppColors.practiceLavenderBackground,
          isDark
              ? AppColors.darkPracticeLavenderIcon
              : AppColors.practiceLavenderIcon,
          Icons.auto_awesome_rounded,
        );
      case PracticeRoomTone.yellow:
        return (
          isDark
              ? AppColors.darkPracticeYellowBackground
              : AppColors.practiceYellowBackground,
          isDark
              ? AppColors.darkPracticeYellowIcon
              : AppColors.practiceYellowIcon,
          Icons.layers_rounded,
        );
      case PracticeRoomTone.mint:
        return (
          isDark
              ? AppColors.darkPracticeMintBackground
              : AppColors.practiceMintBackground,
          isDark ? AppColors.darkPracticeMintIcon : AppColors.practiceMintIcon,
          Icons.star_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMutedDarker;

    final (iconBg, iconColor, iconData) = _toneStyle(context);

    return Semantics(
      button: true,
      label: room.hasCta
          ? '$title. $subtitle. Double tap to start.'
          : '$title, $subtitle. Double tap to open.',
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
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  ),
                  alignment: Alignment.center,
                  child: Icon(iconData, color: iconColor, size: 24.0),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 13.5,
                          color: subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (room.hasCta) ...[
                  const SizedBox(width: AppSpacing.sm),
                  ExcludeSemantics(
                    child: PracticeStartButton(onPressed: onTap),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

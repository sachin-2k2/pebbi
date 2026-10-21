import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Compact round yellow level badge displayed on Pebbi mascot and profile sheets.
///
/// Follows AGENTS.md §4.6 (flexible sizing, minimum constraints) and §8.
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level, this.size = 22.0});

  final int level;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkLevelBadgeBackground
        : AppColors.levelBadgeBackground;

    return Semantics(
      label: 'Level $level',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 3.0,
              offset: Offset(0, 1.5),
            ),
          ],
        ),
        child: Text(
          '$level',
          style: AppTypography.caption.copyWith(
            color: AppColors.levelBadgeText,
            fontSize: size * 0.55,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

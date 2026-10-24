import 'package:flutter/material.dart';
import 'top_pills_row.dart';

/// Legacy export and alias for TopPillsRow.
class TopPills extends StatelessWidget {
  const TopPills({
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
    return TopPillsRow(
      language: language,
      streakCount: streakCount,
      starsCount: starsCount,
      glyph: glyph,
      onLanguageTap: onLanguageTap,
      onStreakTap: onStreakTap,
      onStarsTap: onStarsTap,
      onProfileTap: onProfileTap,
    );
  }
}

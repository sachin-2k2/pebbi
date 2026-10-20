import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Large script character or glyph representing a language's writing system.
///
/// Follows AGENTS.md §3: under 100 lines, const constructor, responsive typography.
class LanguageGlyph extends StatelessWidget {
  const LanguageGlyph({
    super.key,
    required this.glyph,
    this.color = AppColors.textPrimary,
    this.fontSize = 28.0,
  });

  final String glyph;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      glyph,
      style: AppTypography.screenTitle.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.15,
      ),
    );
  }
}

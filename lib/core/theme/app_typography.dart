import 'package:flutter/material.dart';

/// Typography hierarchy for Pebbi supporting dynamic scaling up to 200%.
///
/// Follows AGENTS.md §2 (core/theme) & §8 (design tokens).
/// TextStyles do NOT bake in color, allowing colors to be supplied via [AppPalette]
/// at point of use or inherited from [ThemeData.colorScheme] / [DefaultTextStyle].
abstract final class AppTypography {
  static const String? fontFamily = null;

  // Screen & Large Titles
  static const TextStyle display = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    height: 1.25,
  );

  // Card & Section Titles
  static const TextStyle cardTitle = TextStyle(
    fontSize: 19.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // Card Overlines (e.g., "CONTINUE", "TODAY'S MISSION", "UNIT · 0 OF 3 STOPS DONE")
  static const TextStyle cardOverline = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
    height: 1.2,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  // Button & Interactive Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.2,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.2,
  );

  // Subtitles & Captions
  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle captionSmall = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );
}

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_palette.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// App theme builders for light and dark modes matching the Pebbi specification.
///
/// Follows AGENTS.md §2 (core/theme) & §8 (design tokens).
/// Centralized through [AppPalette] so built-in and custom widgets adapt consistently.
abstract final class AppTheme {
  static ThemeData light([Color accentColor = AppColors.brandPurple]) {
    final palette = AppPalette.light(accentColor);

    final colorScheme = ColorScheme.light(
      primary: palette.accent,
      onPrimary: palette.textOnAccent,
      primaryContainer: palette.brandTint,
      onPrimaryContainer: palette.brand,
      secondary: palette.mint,
      onSecondary: Colors.white,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      surfaceContainer: palette.surfaceVariant,
      surfaceContainerHighest: palette.surfaceRaised,
      error: palette.errorText,
      onError: Colors.white,
      outline: palette.outline,
      outlineVariant: palette.divider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      fontFamily: AppTypography.fontFamily,
      extensions: [palette],
      textTheme:
          const TextTheme(
            displayLarge: AppTypography.display,
            titleLarge: AppTypography.screenTitle,
            titleMedium: AppTypography.cardTitle,
            bodyLarge: AppTypography.bodyLarge,
            bodyMedium: AppTypography.bodyMedium,
            labelLarge: AppTypography.labelLarge,
            labelMedium: AppTypography.labelMedium,
            bodySmall: AppTypography.caption,
          ).apply(
            bodyColor: palette.textPrimary,
            displayColor: palette.textPrimary,
          ),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: BorderSide(color: palette.outline),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        modalBackgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: BorderSide(color: palette.outline),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.navRailBackground,
        indicatorColor: palette.tabBarIndicator,
        selectedIconTheme: IconThemeData(color: palette.brand),
        unselectedIconTheme: IconThemeData(color: palette.textMuted),
        selectedLabelTextStyle: TextStyle(
          color: palette.brand,
          fontWeight: FontWeight.w700,
          fontSize: 13.0,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: palette.textMuted,
          fontWeight: FontWeight.w500,
          fontSize: 13.0,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceRaised,
        contentTextStyle: TextStyle(color: palette.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: BorderSide(color: palette.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.inputFill,
        hintStyle: TextStyle(color: palette.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: BorderSide(color: palette.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: BorderSide(color: palette.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: BorderSide(color: palette.inputFocus, width: 1.5),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData dark([Color accentColor = AppColors.brandPurple]) {
    final palette = AppPalette.dark(accentColor);

    final colorScheme = ColorScheme.dark(
      primary: palette.accent,
      onPrimary: palette.textOnAccent,
      primaryContainer: palette.brandTint,
      onPrimaryContainer: palette.brandText,
      secondary: palette.mint,
      onSecondary: Colors.black,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      surfaceContainer: palette.surfaceVariant,
      surfaceContainerHighest: palette.surfaceRaised,
      error: palette.errorText,
      onError: Colors.black,
      outline: palette.outline,
      outlineVariant: palette.divider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      fontFamily: AppTypography.fontFamily,
      extensions: [palette],
      textTheme:
          const TextTheme(
            displayLarge: AppTypography.display,
            titleLarge: AppTypography.screenTitle,
            titleMedium: AppTypography.cardTitle,
            bodyLarge: AppTypography.bodyLarge,
            bodyMedium: AppTypography.bodyMedium,
            labelLarge: AppTypography.labelLarge,
            labelMedium: AppTypography.labelMedium,
            bodySmall: AppTypography.caption,
          ).apply(
            bodyColor: palette.textPrimary,
            displayColor: palette.textPrimary,
          ),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: BorderSide(color: palette.outline),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        modalBackgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: BorderSide(color: palette.outline),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.navRailBackground,
        indicatorColor: palette.tabBarIndicator,
        selectedIconTheme: IconThemeData(color: palette.brandText),
        unselectedIconTheme: IconThemeData(color: palette.textMuted),
        selectedLabelTextStyle: TextStyle(
          color: palette.brandText,
          fontWeight: FontWeight.w700,
          fontSize: 13.0,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: palette.textMuted,
          fontWeight: FontWeight.w500,
          fontSize: 13.0,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceRaised,
        contentTextStyle: TextStyle(color: palette.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: BorderSide(color: palette.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.inputFill,
        hintStyle: TextStyle(color: palette.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: BorderSide(color: palette.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: BorderSide(color: palette.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          borderSide: BorderSide(color: palette.inputFocus, width: 1.5),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
    );
  }
}

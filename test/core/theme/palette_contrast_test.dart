import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/theme/app_palette.dart';

double _relativeLuminance(Color c) {
  double channel(double v) {
    return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channel(c.r);
  final g = channel(c.g);
  final b = channel(c.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double contrastRatio(Color foreground, Color background) {
  final l1 = _relativeLuminance(foreground);
  final l2 = _relativeLuminance(background);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('WCAG AA Contrast Tests for AppPalette', () {
    test('Light Palette meets WCAG AA standards (>= 4.5:1 text, >= 3.0:1 UI)', () {
      final palette = AppPalette.light();

      final textPairs = <String, (Color, Color)>{
        'textPrimary on background': (palette.textPrimary, palette.background),
        'textPrimary on surface': (palette.textPrimary, palette.surface),
        'textMuted on surface': (palette.textMuted, palette.surface),
        'textMuted on background': (palette.textMuted, palette.background),
        'textOnBrand on brand': (palette.textOnBrand, palette.brand),
        'coralHeroCardMutedText on coralHeroCard': (
          palette.coralHeroCardMutedText,
          palette.coralHeroCard,
        ),
        'successText on successSurface': (
          palette.successText,
          palette.successSurface,
        ),
        'errorText on errorSurface': (palette.errorText, palette.errorSurface),
        'warningText on warningSurface': (
          palette.warningText,
          palette.warningSurface,
        ),
        'infoText on infoSurface': (
          palette.infoText,
          palette.infoSurface,
        ),
        'chipSelectedText on chipSelectedFill': (
          palette.chipSelectedText,
          palette.chipSelectedFill,
        ),
        'chipUnselectedText on chipUnselectedFill': (
          palette.chipUnselectedText,
          palette.chipUnselectedFill,
        ),
      };

      for (final entry in textPairs.entries) {
        final ratio = contrastRatio(entry.value.$1, entry.value.$2);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason:
              'Light text contrast failed for ${entry.key}: ratio is $ratio (expected >= 4.5:1)',
        );
      }

      final nonTextPairs = <String, (Color, Color)>{
        'brand on surface': (palette.brand, palette.surface),
        'mintDepth on surface': (palette.mintDepth, palette.surface),
        'coralDepth on surface': (palette.coralDepth, palette.surface),
        'gold on surface': (palette.gold, palette.surface),
      };

      for (final entry in nonTextPairs.entries) {
        final ratio = contrastRatio(entry.value.$1, entry.value.$2);
        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason:
              'Light non-text contrast failed for ${entry.key}: ratio is $ratio (expected >= 3.0:1)',
        );
      }
    });

    test('Dark Palette meets WCAG AA standards (>= 4.5:1 text, >= 3.0:1 UI)', () {
      final palette = AppPalette.dark();

      final textPairs = <String, (Color, Color)>{
        'textPrimary on background': (palette.textPrimary, palette.background),
        'textPrimary on surface': (palette.textPrimary, palette.surface),
        'textPrimary on surfaceVariant': (
          palette.textPrimary,
          palette.surfaceVariant,
        ),
        'textMuted on background': (palette.textMuted, palette.background),
        'textMuted on surface': (palette.textMuted, palette.surface),
        'textMuted on surfaceVariant': (
          palette.textMuted,
          palette.surfaceVariant,
        ),
        'textOnBrand on brand': (palette.textOnBrand, palette.brand),
        'brandText on surface': (palette.brandText, palette.surface),
        'successText on successSurface': (
          palette.successText,
          palette.successSurface,
        ),
        'errorText on errorSurface': (palette.errorText, palette.errorSurface),
        'warningText on warningSurface': (
          palette.warningText,
          palette.warningSurface,
        ),
        'infoText on infoSurface': (
          palette.infoText,
          palette.infoSurface,
        ),
        'chipSelectedText on chipSelectedFill': (
          palette.chipSelectedText,
          palette.chipSelectedFill,
        ),
        'chipUnselectedText on chipUnselectedFill': (
          palette.chipUnselectedText,
          palette.chipUnselectedFill,
        ),
      };

      for (final entry in textPairs.entries) {
        final ratio = contrastRatio(entry.value.$1, entry.value.$2);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason:
              'Dark text contrast failed for ${entry.key}: ratio is $ratio (expected >= 4.5:1)',
        );
      }

      final nonTextPairs = <String, (Color, Color)>{
        'gold on surface': (palette.gold, palette.surface),
        'mint on surface': (palette.mint, palette.surface),
        'coral on surface': (palette.coral, palette.surface),
      };

      for (final entry in nonTextPairs.entries) {
        final ratio = contrastRatio(entry.value.$1, entry.value.$2);
        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason:
              'Dark non-text contrast failed for ${entry.key}: ratio is $ratio (expected >= 3.0:1)',
        );
      }
    });
  });
}

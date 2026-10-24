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
  group('Tag & Playing Row Contrast Tests (WCAG AA >= 4.5:1 text, >= 3.0:1 UI)', () {
    test('Light Palette meets WCAG AA standards for all tag tones & playing row', () {
      final palette = AppPalette.light();

      final textPairs = <String, (Color, Color)>{
        'tagGrammarText on tagGrammarFill': (
          palette.tagGrammarText,
          palette.tagGrammarFill,
        ),
        'tagCultureText on tagCultureFill': (
          palette.tagCultureText,
          palette.tagCultureFill,
        ),
        'tagNeutralText on tagNeutralFill': (
          palette.tagNeutralText,
          palette.tagNeutralFill,
        ),
        'playingRowText on playingRowFill': (
          palette.playingRowText,
          palette.playingRowFill,
        ),
        'playingRowMutedText on playingRowFill': (
          palette.playingRowMutedText,
          palette.playingRowFill,
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

      final uiPairs = <String, (Color, Color)>{
        'playingRowBorder on surface': (
          palette.playingRowBorder,
          palette.surface,
        ),
      };

      for (final entry in uiPairs.entries) {
        final ratio = contrastRatio(entry.value.$1, entry.value.$2);
        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason:
              'Light UI contrast failed for ${entry.key}: ratio is $ratio (expected >= 3.0:1)',
        );
      }
    });

    test('Dark Palette meets WCAG AA standards for all tag tones & playing row', () {
      final palette = AppPalette.dark();

      final textPairs = <String, (Color, Color)>{
        'tagGrammarText on tagGrammarFill': (
          palette.tagGrammarText,
          palette.tagGrammarFill,
        ),
        'tagCultureText on tagCultureFill': (
          palette.tagCultureText,
          palette.tagCultureFill,
        ),
        'tagNeutralText on tagNeutralFill': (
          palette.tagNeutralText,
          palette.tagNeutralFill,
        ),
        'playingRowText on playingRowFill': (
          palette.playingRowText,
          palette.playingRowFill,
        ),
        'playingRowMutedText on playingRowFill': (
          palette.playingRowMutedText,
          palette.playingRowFill,
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

      final uiPairs = <String, (Color, Color)>{
        'playingRowBorder on surface': (
          palette.playingRowBorder,
          palette.surface,
        ),
      };

      for (final entry in uiPairs.entries) {
        final ratio = contrastRatio(entry.value.$1, entry.value.$2);
        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason:
              'Dark UI contrast failed for ${entry.key}: ratio is $ratio (expected >= 3.0:1)',
        );
      }
    });
  });
}

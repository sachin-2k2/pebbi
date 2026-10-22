/// Pure Dart domain rules for in-app text scale calculations.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
abstract final class TextSizeRules {
  /// Minimum allowed in-app text scale factor (85%).
  static const double minTextScale = 0.85;

  /// Maximum allowed in-app text scale factor (130%).
  static const double maxTextScale = 1.30;

  /// Slider step increment (5%).
  static const double step = 0.05;

  /// Default in-app scale factor (100%).
  static const double defaultScale = 1.0;

  /// Maximum combined text scale factor allowed before layout clipping (200%).
  static const double maxCombinedScale = 2.0;

  /// Number of discrete slider steps.
  static int get divisions => ((maxTextScale - minTextScale) / step).round();

  /// Snaps [rawScale] to the nearest valid step and clamps between [minTextScale] and [maxTextScale].
  static double snapScale(double rawScale) {
    final clamped = rawScale.clamp(minTextScale, maxTextScale);
    final stepsFromMin = ((clamped - minTextScale) / step).round();
    final snapped = minTextScale + (stepsFromMin * step);
    // Round to 2 decimal places to avoid IEEE 754 precision artifacts
    return double.parse(snapped.toStringAsFixed(2));
  }

  /// Calculates the effective text scale factor combining [systemScale] and [inAppScale],
  /// strictly capped at [maxCombinedScale] (200%) per AGENTS.md §4.1 rule 5.
  static double clampCombinedScale({
    required double systemScale,
    required double inAppScale,
  }) {
    final combined = systemScale * inAppScale;
    return combined.clamp(0.5, maxCombinedScale);
  }

  /// Formats the [inAppScale] as an integer percentage string (e.g. 1.0 -> '100%').
  static String formatPercent(double inAppScale) {
    final percent = (inAppScale * 100).round();
    return '$percent%';
  }
}

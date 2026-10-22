import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/text_size_rules.dart';

/// Accessible slider controlling the in-app text scale factor.
///
/// Follows AGENTS.md §3 & §4: 48dp touch target, WCAG visible tracks, discrete steps.
class TextSizeSlider extends StatelessWidget {
  const TextSizeSlider({
    super.key,
    required this.currentScale,
    required this.onChanged,
  });

  final double currentScale;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.brandPurple;
    final inactiveColor = isDark
        ? AppColors.darkBorder
        : AppColors.settingsSliderInactiveTrack;

    final percentString = TextSizeRules.formatPercent(currentScale);

    return Semantics(
      label: 'Text size, $percentString',
      slider: true,
      value: percentString,
      increasedValue: TextSizeRules.formatPercent(
        TextSizeRules.snapScale(currentScale + TextSizeRules.step),
      ),
      decreasedValue: TextSizeRules.formatPercent(
        TextSizeRules.snapScale(currentScale - TextSizeRules.step),
      ),
      onIncrease: () {
        final next = TextSizeRules.snapScale(currentScale + TextSizeRules.step);
        onChanged(next);
      },
      onDecrease: () {
        final prev = TextSizeRules.snapScale(currentScale - TextSizeRules.step);
        onChanged(prev);
      },
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 6.0,
          activeTrackColor: activeColor,
          inactiveTrackColor: inactiveColor,
          thumbColor: activeColor,
          overlayColor: activeColor.withValues(alpha: 0.15),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
        ),
        child: SizedBox(
          height: 48.0,
          child: Slider(
            value: currentScale.clamp(
              TextSizeRules.minTextScale,
              TextSizeRules.maxTextScale,
            ),
            min: TextSizeRules.minTextScale,
            max: TextSizeRules.maxTextScale,
            divisions: TextSizeRules.divisions,
            onChanged: (val) => onChanged(TextSizeRules.snapScale(val)),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';

/// Dynamic, width-adaptive audio level meter displaying a row of pale purple dots.
///
/// Follows AGENTS.md §4.1: The dot count adapts to available width via LayoutBuilder,
/// never hardcoded. Adheres to Reduce Motion accessibility rules.
class LevelDots extends StatelessWidget {
  const LevelDots({
    super.key,
    required this.soundLevel,
    required this.isListening,
  });

  /// Normalized sound level (0.0 to 1.0) from the microphone.
  final double soundLevel;

  /// Whether the microphone is currently active.
  final bool isListening;

  static const double _dotSize = 6.0;
  static const double _spacing = 8.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final inactiveColor = isDark
        ? AppColors.darkBorder
        : AppColors.brandPurple.withValues(alpha: 0.20);
    final activeColor = isDark
        ? AppColors.brandPurpleLight
        : AppColors.brandPurple;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Compute how many dots fit comfortably centered
        final dotUnit = _dotSize + _spacing;
        final maxDots = ((availableWidth) / dotUnit).floor();
        final count = maxDots.clamp(8, 22);

        final activeCount = (!isListening || reduceMotion)
            ? 0
            : (count * soundLevel).clamp(1.0, count.toDouble()).round();

        return SizedBox(
          height: 16.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              // Light up dots from center outwards or left to right
              final isActive = index < activeCount;
              return Container(
                width: _dotSize,
                height: _dotSize,
                margin: const EdgeInsets.symmetric(horizontal: _spacing / 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? activeColor : inactiveColor,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

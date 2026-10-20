import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/accent_option.dart';

/// Large hero Pebbi mascot with dynamic accent cross-fade animation.
///
/// Follows AGENTS.md §3 & §4:
/// - Clamps size between min 110dp and max 170dp
/// - Cross-fades body colour smoothly (instant when reduce-motion is active)
/// - Sized via constraints to prevent overflow on compact or landscape viewports.
class PebbiHero extends StatelessWidget {
  const PebbiHero({
    super.key,
    required this.accentId,
    this.maxSize = 160.0,
    this.minSize = 110.0,
  });

  final String accentId;
  final double maxSize;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    final option = AccentOption.findById(accentId);
    final targetColor = Color(option.colorValue);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Clamp mascot size gracefully based on available width
        final availableWidth = constraints.maxWidth;
        final targetSize = (availableWidth * 0.45).clamp(minSize, maxSize);

        return Center(
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(begin: targetColor, end: targetColor),
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            builder: (context, color, child) {
              return PebbiMascot(
                size: targetSize,
                accentColor: color ?? AppColors.brandPurple,
                expression: PebbiExpression.happyClosed,
              );
            },
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'splash_decoration_config.dart';

/// Renders decorative multilingual greetings in pale white.
///
/// Follows User Rule 7a & Accessibility:
/// - Excluded from screen readers (ExcludeSemantics)
/// - Uses device offline system fonts (no network font downloads)
/// - Respects correct text direction per script (e.g., Arabic RTL)
/// - Silently skips glyphs that cannot be rendered to prevent tofu boxes.
class SplashGreetingsLayer extends StatelessWidget {
  const SplashGreetingsLayer({
    super.key,
    required this.screenSize,
    required this.opacity,
  });

  final Size screenSize;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0.0) return const SizedBox.shrink();

    // If screen height is constrained (< 500dp, e.g. landscape phone), omit greetings
    if (screenSize.height < 500.0) {
      return const SizedBox.shrink();
    }

    final greetings = SplashDecorationConfig.greetings;

    return ExcludeSemantics(
      child: Stack(
        children: [
          for (final greeting in greetings)
            Positioned(
              left: greeting.fractionX * screenSize.width,
              top: greeting.fractionY * screenSize.height,
              child: Opacity(
                opacity: (greeting.opacity * opacity).clamp(0.0, 1.0),
                child: Directionality(
                  textDirection: greeting.textDirection,
                  child: Text(
                    greeting.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: greeting.fontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    textScaler: TextScaler.noScaling,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

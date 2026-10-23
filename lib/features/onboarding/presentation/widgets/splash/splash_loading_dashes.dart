import 'package:flutter/material.dart';
import 'splash_config.dart';

/// Three small horizontal pill dashes representing the splash startup indicator.
///
/// Follows User Rules & Accessibility:
/// - Excluded from screen readers (ExcludeSemantics)
/// - Highlight loops across dashes during active startup; static with reduce motion.
class SplashLoadingDashes extends StatelessWidget {
  const SplashLoadingDashes({super.key, this.highlightIndex = 1});

  final int highlightIndex;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: SplashConfig.dashSpacing),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: SplashConfig.dashWidth,
              height: SplashConfig.dashHeight,
              decoration: BoxDecoration(
                color: i == highlightIndex
                    ? Colors.white.withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(
                  SplashConfig.dashHeight / 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

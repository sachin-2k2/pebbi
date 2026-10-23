import 'package:flutter/material.dart';
import '../../../../../core/design_system/pebbi_mascot.dart';
import 'splash_config.dart';

/// Central 96x96dp Logo Tile with entrance shadow glow and sparkle.
///
/// Follows User Rules 2 & 3:
/// - Fixed 96dp size (not scaled by window width, text scale, or tablet)
/// - Native asset has no glow/shadow/sparkle; Flutter fades them in during entrance.
class SplashLogoTile extends StatelessWidget {
  const SplashLogoTile({
    super.key,
    this.glowOpacity = 1.0,
    this.sparkleOpacity = 1.0,
  });

  final double glowOpacity;
  final double sparkleOpacity;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pebbi',
      image: true,
      child: SizedBox(
        width: SplashConfig.tileLogicalSize,
        height: SplashConfig.tileLogicalSize,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Soft glow / shadow behind the tile (fades in)
            if (glowOpacity > 0.0)
              Positioned.fill(
                child: Opacity(
                  opacity: glowOpacity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x66000000),
                          blurRadius: 28.0,
                          spreadRadius: 2.0,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: const Color(0x334B33C4),
                          blurRadius: 40.0,
                          spreadRadius: 8.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Logo tile body (96x96 white rounded card with mascot)
            Container(
              width: SplashConfig.tileLogicalSize,
              height: SplashConfig.tileLogicalSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/splash/pebbi_logo_tile.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: PebbiMascot(
                      size: 64.0,
                      expression: PebbiExpression.happy,
                    ),
                  );
                },
              ),
            ),

            // Top-right Sparkle icon
            if (sparkleOpacity > 0.0)
              Positioned(
                top: -12.0,
                right: -12.0,
                child: Opacity(
                  opacity: sparkleOpacity,
                  child: Image.asset(
                    'assets/images/splash/splash_sparkle.png',
                    width: 32.0,
                    height: 32.0,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.auto_awesome,
                        size: 28.0,
                        color: Color(0xFFFFD159),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

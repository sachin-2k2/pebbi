import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import 'splash_config.dart';
import 'splash_decoration_config.dart';
import 'splash_decoration_item.dart';
import 'splash_greetings_layer.dart';
import 'splash_loading_dashes.dart';
import 'splash_logo_tile.dart';
import 'splash_wordmark.dart';

/// Full splash layout rendering background, centered tile, wordmark, and decorations.
///
/// Follows AGENTS.md §4:
/// - Logo tile center is at exact screen center (W/2, H/2)
/// - Wordmark, tagline, and dashes sit strictly below tile
/// - Background cross-fades from solid launch color to gradient.
class SplashContent extends StatelessWidget {
  const SplashContent({
    super.key,
    required this.gradientOpacity,
    required this.wordmarkOpacity,
    required this.wordmarkSlide,
    required this.decorationsOpacity,
    required this.sparkleOpacity,
    required this.dashesOpacity,
    required this.dashAnimation,
    required this.driftOffset,
    required this.showArt,
    this.reduceMotion = false,
  });

  final double gradientOpacity;
  final double wordmarkOpacity;
  final double wordmarkSlide;
  final double decorationsOpacity;
  final double sparkleOpacity;
  final double dashesOpacity;
  final Animation<double> dashAnimation;
  final Offset driftOffset;
  final bool showArt;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final screenSize = MediaQuery.sizeOf(context);
    final cx = screenSize.width / 2;
    final cy = screenSize.height / 2;

    return Stack(
      children: [
        // Solid launch background color (matches native frame 1)
        Positioned.fill(
          child: ColoredBox(color: palette.splashBackgroundSolid),
        ),

        // Gradient cross-fade
        if (showArt && gradientOpacity > 0.0)
          Positioned.fill(
            child: Opacity(
              opacity: gradientOpacity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      palette.splashGradientTop,
                      palette.splashGradientBottom,
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Floating decorative items (only when art enabled)
        if (showArt && decorationsOpacity > 0.0 && screenSize.height >= 400.0)
          for (final item in SplashDecorationConfig.floatingItems)
            Positioned(
              left: item.fractionX * screenSize.width,
              top: item.fractionY * screenSize.height,
              child: SplashDecorationItem(
                item: item,
                opacity: decorationsOpacity,
                driftOffset: driftOffset,
              ),
            ),

        // Multilingual greetings layer (only when art enabled)
        if (showArt && decorationsOpacity > 0.0)
          SplashGreetingsLayer(
            screenSize: screenSize,
            opacity: decorationsOpacity,
          ),

        // Centered Logo Tile (Exact Center of Screen)
        Positioned(
          left: cx - (SplashConfig.tileLogicalSize / 2),
          top: cy - (SplashConfig.tileLogicalSize / 2),
          child: SplashLogoTile(
            glowOpacity: showArt ? gradientOpacity : 0.0,
            sparkleOpacity: showArt ? sparkleOpacity : 0.0,
          ),
        ),

        // Wordmark, Tagline, and Loading Dashes below the Tile
        if (showArt)
          Positioned(
            left: 0,
            right: 0,
            top: cy + (SplashConfig.tileLogicalSize / 2) + 12.0 + wordmarkSlide,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Opacity(
                  opacity: wordmarkOpacity,
                  child: const SplashWordmark(),
                ),
                const SizedBox(height: 14.0),
                Opacity(
                  opacity: dashesOpacity,
                  child: SplashLoadingDashes(
                    animation: dashAnimation,
                    reduceMotion: reduceMotion,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

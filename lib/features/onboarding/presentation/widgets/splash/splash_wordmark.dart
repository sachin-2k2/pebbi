import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import 'splash_config.dart';

/// Renders the chunky "Pebbi" wordmark image asset and the tagline below it.
///
/// Follows User Rule 7b & Accessibility:
/// - Wordmark is an image asset, not live text
/// - Tagline is localized / English default, with reserved width to avoid layout shifts
/// - Clamps combined text scale so text stays legible without breaking safe bounds.
class SplashWordmark extends StatelessWidget {
  const SplashWordmark({super.key, this.tagline = 'Speak it for real.'});

  final String tagline;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final textScale = media.textScaler.scale(1.0).clamp(0.85, 1.35);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // "Tutotoco" Wordmark
        Semantics(
          label: 'Tutotoco',
          child: Text(
            'Tutotoco',
            style: AppTypography.display.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 32.0,
              letterSpacing: -0.5,
            ),
          ),
        ),

        const SizedBox(height: 6.0),

        // Tagline with reserved width
        SizedBox(
          width: SplashConfig.taglineReservedWidth,
          child: MediaQuery(
            data: media.copyWith(textScaler: TextScaler.linear(textScale)),
            child: Text(
              tagline,
              textAlign: TextAlign.center,
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                shadows: const [
                  Shadow(
                    color: Color(0x33000000),
                    blurRadius: 4.0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

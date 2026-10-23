import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/core/theme/app_palette.dart';

void main() {
  group('Splash Color Consistency Tests (AGENTS.md & User Rule 1)', () {
    test(
      'solid launch colour equals gradient colour at tile centre (50% height) within 1/255',
      () {
        final top = AppColors.splashGradientTop;
        final bottom = AppColors.splashGradientBottom;
        final solid = AppColors.splashBackgroundSolid;

        // Linear vertical gradient sampled at 50% height:
        final mid = Color.lerp(top, bottom, 0.5)!;

        final diffR = (mid.r * 255.0 - solid.r * 255.0).abs();
        final diffG = (mid.g * 255.0 - solid.g * 255.0).abs();
        final diffB = (mid.b * 255.0 - solid.b * 255.0).abs();

        // Within 1/255 per channel:
        expect(
          diffR,
          lessThanOrEqualTo(1.0),
          reason: 'Red channel delta must be <= 1/255',
        );
        expect(
          diffG,
          lessThanOrEqualTo(1.0),
          reason: 'Green channel delta must be <= 1/255',
        );
        expect(
          diffB,
          lessThanOrEqualTo(1.0),
          reason: 'Blue channel delta must be <= 1/255',
        );
      },
    );

    test(
      'AppPalette exposes identical splash colors in light and dark modes',
      () {
        final light = AppPalette.light();
        final dark = AppPalette.dark();

        expect(
          light.splashBackgroundSolid,
          equals(AppColors.splashBackgroundSolid),
        );
        expect(
          dark.splashBackgroundSolid,
          equals(AppColors.splashBackgroundSolid),
        );

        expect(light.splashGradientTop, equals(AppColors.splashGradientTop));
        expect(dark.splashGradientTop, equals(AppColors.splashGradientTop));

        expect(
          light.splashGradientBottom,
          equals(AppColors.splashGradientBottom),
        );
        expect(
          dark.splashGradientBottom,
          equals(AppColors.splashGradientBottom),
        );
      },
    );
  });
}

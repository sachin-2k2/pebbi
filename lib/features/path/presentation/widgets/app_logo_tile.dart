import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_palette.dart';

/// Top app logo tile with mascot face and sparkle badge.
///
/// Follows AGENTS.md §3 & §4: under 60 lines, build under 50 lines.
class AppLogoTile extends StatelessWidget {
  const AppLogoTile({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: palette.outline, width: 1.0),
        boxShadow: palette.cardShadow,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          PebbiMascot(
            size: 28.0,
            accentColor: palette.brand,
            expression: PebbiExpression.happy,
          ),
          const Positioned(
            top: -4.0,
            right: -4.0,
            child: Text('✨', style: TextStyle(fontSize: 12.0, height: 1.0)),
          ),
        ],
      ),
    );
  }
}

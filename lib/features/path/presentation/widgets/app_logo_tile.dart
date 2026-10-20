import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';

/// Top app logo tile with mascot face and sparkle badge.
///
/// Follows AGENTS.md §3 & §4: under 60 lines, build under 50 lines.
class AppLogoTile extends StatelessWidget {
  const AppLogoTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1E1647),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: const [
          PebbiMascot(size: 28.0, expression: PebbiExpression.happy),
          Positioned(
            top: -4.0,
            right: -4.0,
            child: Text('✨', style: TextStyle(fontSize: 12.0, height: 1.0)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';

/// Small "NEXT" indicator tag hovering above the current node.
class NextTag extends StatelessWidget {
  const NextTag({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: palette.brand,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        boxShadow: [
          BoxShadow(
            color: palette.brand.withValues(alpha: 0.3),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        AppStrings.nextTag,
        style: TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.w800,
          color: palette.textOnBrand,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

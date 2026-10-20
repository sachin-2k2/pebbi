import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';

/// Small "NEXT" indicator tag hovering above the current node.
class NextTag extends StatelessWidget {
  const NextTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: AppColors.brandPurple,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        boxShadow: const [
          BoxShadow(
            color: Color(0x336C4DF6),
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        AppStrings.nextTag,
        style: TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

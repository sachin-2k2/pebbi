import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable error banner for authentication screens with live semantics announcement.
///
/// Follows AGENTS.md §3 & §4: under 60 lines, accessible live region, error tokens.
class GeneralErrorBanner extends StatelessWidget {
  const GeneralErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.errorBorder, width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.errorTextHeader,
            size: 20.0,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.errorTextHeader,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

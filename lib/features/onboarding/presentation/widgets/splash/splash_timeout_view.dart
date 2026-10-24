import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Error overlay displayed if cold-start startup exceeds the hard safety timeout.
///
/// Follows AGENTS.md §2 (core/design_system, theme tokens), §3 (< 150 lines), §4 (responsive).
class SplashTimeoutView extends StatelessWidget {
  const SplashTimeoutView({
    super.key,
    required this.onRetry,
    required this.onContinueGuest,
  });

  final VoidCallback onRetry;
  final VoidCallback onContinueGuest;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              boxShadow: palette.cardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 44.0,
                  color: palette.warningText,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Starting up took longer than expected',
                  style: AppTypography.cardTitle.copyWith(
                    color: palette.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'We had trouble initializing the app. Please try again.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: palette.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                Button3D(
                  label: 'Retry',
                  onPressed: onRetry,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: onContinueGuest,
                  child: Text(
                    'Continue as guest',
                    style: AppTypography.labelLarge.copyWith(
                      color: palette.brand,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

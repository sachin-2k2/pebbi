import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Note card shown at the bottom of the free unit per screenshot 2 and design spec §5.
class FreeUnitNote extends StatelessWidget {
  const FreeUnitNote({super.key, this.onUnlockTap});

  final VoidCallback? onUnlockTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.tintLavender.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: AppColors.tintLavender,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(
              Icons.lock_open_rounded,
              color: AppColors.brandPurple,
              size: 20.0,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.freeUnitNoteTitle,
                  style: AppTypography.cardTitle.copyWith(fontSize: 14.0),
                ),
                const SizedBox(height: 2.0),
                Text(
                  AppStrings.freeUnitNoteSubtitle,
                  style: AppTypography.captionSmall,
                ),
              ],
            ),
          ),
          if (onUnlockTap != null) ...[
            const SizedBox(width: AppSpacing.xs),
            TextButton(
              onPressed: onUnlockTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                minimumSize: const Size(48.0, 48.0),
              ),
              child: const Text(
                'Unlock',
                style: TextStyle(
                  color: AppColors.brandPurple,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

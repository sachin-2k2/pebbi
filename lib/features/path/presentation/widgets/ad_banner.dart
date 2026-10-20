import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Ad banner for free tier users per design spec §5 & §8.
///
/// Price is passed dynamically (not hardcoded) from store/entitlements.
class AdBanner extends StatelessWidget {
  const AdBanner({
    super.key,
    required this.priceString,
    required this.onRemoveAdsTap,
    this.title = 'Learn faster without interruptions',
  });

  final String priceString;
  final VoidCallback onRemoveAdsTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppSpacing.cardShadow,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tintLavender,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: const Text(
                  'AD',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandPurple,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Text('Sponsored', style: AppTypography.captionSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(title, style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            button: true,
            label: 'Remove ads, Premium $priceString',
            child: Material(
              color: AppColors.disabled,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: InkWell(
                onTap: onRemoveAdsTap,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 18.0,
                        color: AppColors.brandPurple,
                      ),
                      const SizedBox(width: 4.0),
                      Flexible(
                        child: Text(
                          'Remove ads · Premium $priceString',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

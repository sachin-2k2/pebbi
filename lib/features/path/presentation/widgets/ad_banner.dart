import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
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
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: palette.outline),
        boxShadow: palette.cardShadow,
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
                  color: palette.tintLavender,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  'AD',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w800,
                    color: palette.brandText,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Sponsored',
                style: AppTypography.captionSmall.copyWith(
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            button: true,
            label: 'Remove ads, Premium $priceString',
            child: Material(
              color: palette.surfaceVariant,
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
                    border: Border.all(color: palette.outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 18.0,
                        color: palette.brandText,
                      ),
                      const SizedBox(width: 4.0),
                      Flexible(
                        child: Text(
                          'Remove ads · Premium $priceString',
                          style: AppTypography.caption.copyWith(
                            color: palette.textPrimary,
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

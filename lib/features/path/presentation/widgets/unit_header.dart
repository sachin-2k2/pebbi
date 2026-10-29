import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Full-width brand purple unit banner with guidebook action and progress bar.
class UnitHeader extends StatelessWidget {
  const UnitHeader({
    super.key,
    required this.unitNumber,
    required this.title,
    required this.stopsDone,
    required this.totalStops,
    this.onGuidebookTap,
    this.guidebookFocusNode,
    this.isLocked = false,
  });

  final int unitNumber;
  final String title;
  final int stopsDone;
  final int totalStops;
  final VoidCallback? onGuidebookTap;
  final FocusNode? guidebookFocusNode;
  final bool isLocked;

  double get _progress =>
      totalStops > 0 ? (stopsDone / totalStops).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bgColor = isLocked ? palette.surfaceRaised : palette.brand;
    final titleColor = isLocked ? palette.textPrimary : palette.textOnBrand;
    final overlineColor = isLocked
        ? palette.textMuted
        : palette.textOnBrand.withValues(alpha: 0.85);
    final iconColor = isLocked ? palette.textMuted : palette.textOnBrand;
    final progressBgColor = isLocked
        ? palette.outline.withValues(alpha: 0.25)
        : palette.textOnBrand.withValues(alpha: 0.25);
    final progressValColor = isLocked
        ? palette.brand.withValues(alpha: 0.5)
        : palette.textOnBrand;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: isLocked
            ? Border.all(color: palette.outline.withValues(alpha: 0.5))
            : null,
        boxShadow: palette.cardShadow,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isLocked) ...[
                Icon(
                  Icons.lock_rounded,
                  size: 13.0,
                  color: overlineColor,
                ),
                const SizedBox(width: 4.0),
              ],
              Expanded(
                child: Text(
                  '${AppStrings.unitHeaderPrefix} $unitNumber · $stopsDone ${AppStrings.unitHeaderStopsOf} $totalStops ${AppStrings.unitHeaderStopsDone}',
                  style: AppTypography.cardOverline.copyWith(
                    color: overlineColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onGuidebookTap != null)
                IconButton(
                  focusNode: guidebookFocusNode,
                  icon: Icon(Icons.menu_book_rounded, color: iconColor),
                  iconSize: 22.0,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 48.0,
                    minHeight: 48.0,
                  ),
                  onPressed: onGuidebookTap,
                  tooltip: AppStrings.guidebookTooltip,
                ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            title,
            style: AppTypography.screenTitle.copyWith(color: titleColor),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 6.0,
              backgroundColor: progressBgColor,
              valueColor: AlwaysStoppedAnimation<Color>(progressValColor),
            ),
          ),
        ],
      ),
    );
  }
}

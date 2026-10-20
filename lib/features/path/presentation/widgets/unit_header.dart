import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
    this.isLocked = false,
  });

  final int unitNumber;
  final String title;
  final int stopsDone;
  final int totalStops;
  final VoidCallback? onGuidebookTap;
  final bool isLocked;

  double get _progress =>
      totalStops > 0 ? (stopsDone / totalStops).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final bgColor = isLocked ? const Color(0xFF5A45A0) : AppColors.brandPurple;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color(0x266C4DF6),
            blurRadius: 16.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${AppStrings.unitHeaderPrefix} $unitNumber · $stopsDone ${AppStrings.unitHeaderStopsOf} $totalStops ${AppStrings.unitHeaderStopsDone}',
                  style: AppTypography.cardOverline.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onGuidebookTap != null)
                IconButton(
                  icon: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                  ),
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
            style: AppTypography.screenTitle.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 6.0,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

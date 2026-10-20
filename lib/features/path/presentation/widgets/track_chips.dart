import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class TrackChipData {
  const TrackChipData({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

/// Horizontally scrollable track chips with hidden scrollbar per design spec §5 & §8.
class TrackChips extends StatelessWidget {
  const TrackChips({
    super.key,
    required this.tracks,
    required this.selectedTrackId,
    required this.onTrackSelected,
  });

  final List<TrackChipData> tracks;
  final String selectedTrackId;
  final ValueChanged<String> onTrackSelected;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: tracks.map((track) {
            final isSelected = track.id == selectedTrackId;

            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _TrackChipItem(
                track: track,
                isSelected: isSelected,
                onTap: () => onTrackSelected(track.id),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TrackChipItem extends StatelessWidget {
  const _TrackChipItem({
    required this.track,
    required this.isSelected,
    required this.onTap,
  });

  final TrackChipData track;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? AppColors.tintLavender : AppColors.surface;
    final border = isSelected ? AppColors.brandPurple : AppColors.borderLight;
    final fg = isSelected ? AppColors.brandPurple : AppColors.textMuted;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: border, width: isSelected ? 1.5 : 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(track.icon, size: 18.0, color: fg),
              const SizedBox(width: AppSpacing.xs),
              Text(
                track.label,
                style: AppTypography.labelMedium.copyWith(
                  color: fg,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

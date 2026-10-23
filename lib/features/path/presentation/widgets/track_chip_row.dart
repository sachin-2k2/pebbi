import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/track.dart';

/// Horizontally scrollable row of track chips per design spec §5 and screenshot 1.
class TrackChipRow extends StatelessWidget {
  const TrackChipRow({
    super.key,
    required this.tracks,
    required this.selectedTrackId,
    required this.onTrackSelected,
  });

  final List<Track> tracks;
  final String selectedTrackId;
  final ValueChanged<String> onTrackSelected;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: tracks.map((track) {
            final isSelected = track.id == selectedTrackId;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _TrackChip(
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

class _TrackChip extends StatelessWidget {
  const _TrackChip({
    required this.track,
    required this.isSelected,
    required this.onTap,
  });

  final Track track;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bg = isSelected ? palette.brandTint : palette.surface;
    final border = isSelected ? palette.brand : palette.outline;
    final fg = isSelected ? palette.brandText : palette.textMuted;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${track.title} track',
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Container(
            constraints: const BoxConstraints(minHeight: 40.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: border, width: isSelected ? 1.5 : 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (track.emoji.isNotEmpty) ...[
                  Text(track.emoji, style: const TextStyle(fontSize: 14.0)),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  track.title,
                  style: AppTypography.labelMedium.copyWith(
                    color: fg,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

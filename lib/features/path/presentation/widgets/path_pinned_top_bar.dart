import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/home_summary.dart';
import '../../domain/track.dart';
import '../providers/path_provider.dart';
import 'top_pills.dart';
import 'track_chip_row.dart';

/// Pinned top status bar on the Path screen that never scrolls away.
///
/// Follows AGENTS.md §3 (<100 lines) and Candy Crush map UX:
/// - Language switcher, streak count, stars, and profile avatar.
/// - Horizontal track chips for switching learning goals.
class PathPinnedTopBar extends ConsumerWidget {
  const PathPinnedTopBar({
    super.key,
    required this.summary,
    required this.tracks,
    required this.selectedTrack,
  });

  final HomeSummary summary;
  final List<Track> tracks;
  final String selectedTrack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TopPills(
          language: summary.language,
          streakCount: summary.streakCount,
          starsCount: summary.starsCount,
          onLanguageTap: () => _showPlaceholder(context, 'Language switcher'),
          onStreakTap: () => _showPlaceholder(context, 'Streak calendar'),
          onStarsTap: () => _showPlaceholder(context, 'Stars & outfits'),
          onProfileTap: () => context.go('/settings'),
        ),
        const SizedBox(height: AppSpacing.xs),
        TrackChipRow(
          tracks: tracks,
          selectedTrackId: selectedTrack,
          onTrackSelected: (id) =>
              ref.read(selectedTrackProvider.notifier).state = id,
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }

  void _showPlaceholder(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('TODO(question): $feature coming soon!')),
    );
  }
}


import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable model capturing live user stats from track curriculum and submissions.
///
/// Follows AGENTS.md §2.2 & §2.3: Pure Dart, zero Flutter imports.
class TrackStats {
  const TrackStats({this.streak = 0, this.stars = 0, this.xp = 0});

  final int streak;
  final int stars;
  final int xp;
}

/// StateNotifier storing updated streak, stars, and XP from the backend.
class TrackStatsNotifier extends StateNotifier<TrackStats> {
  TrackStatsNotifier() : super(const TrackStats());

  void update({int? streak, int? stars, int? xp}) {
    state = TrackStats(
      streak: streak ?? state.streak,
      stars: stars ?? state.stars,
      xp: xp ?? state.xp,
    );
  }
}

/// Global provider for real-time track and user totals.
final trackStatsProvider =
    StateNotifierProvider<TrackStatsNotifier, TrackStats>((ref) {
      return TrackStatsNotifier();
    });

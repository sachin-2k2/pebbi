import 'track.dart';
import 'unit.dart';

/// Repository interface managing learning tracks, course units, and nodes.
///
/// Follows AGENTS.md §2.2: Pure Dart interface with zero Flutter imports.
abstract interface class PathRepository {
  /// Fetches all available tracks with active content.
  Future<List<Track>> getTracks();

  /// Fetches all units and their node graph for the specified [trackId] and [userId].
  Future<List<Unit>> getUnitsForTrack(
    String trackId, {
    required String userId,
    bool isPremium = false,
  });
}

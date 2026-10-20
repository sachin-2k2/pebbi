import 'mission_category.dart';
import 'mission_summary.dart';
import 'today_mission.dart';

/// Abstract contract for fetching role-play missions and category taxonomy.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
abstract class MissionRepository {
  /// Fetches available mission categories.
  Future<List<MissionCategory>> getCategories({
    required String targetLanguageCode,
  });

  /// Fetches all mission summaries scoped to the given [userId] and [targetLanguageCode].
  Future<List<MissionSummary>> getMissions({
    required String targetLanguageCode,
    required String userId,
  });

  /// Fetches today's featured mission for [userId], or null if none available.
  Future<TodayMission?> getTodayMission({
    required String targetLanguageCode,
    required String userId,
  });

  /// Updates the per-user status of a mission (e.g. marking as done or in-progress).
  Future<void> updateMissionStatus({
    required String userId,
    required String missionId,
    required MissionStatus status,
  });

  /// Marks today's featured mission as completed for [userId].
  Future<void> completeTodayMission({required String userId});
}

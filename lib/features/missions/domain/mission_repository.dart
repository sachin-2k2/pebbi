import 'mission_brief.dart';
import 'mission_category.dart';
import 'mission_mode.dart';
import 'mission_summary.dart';
import 'mission_support.dart';
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

  /// Loads the full mission brief details for [missionId] scoped to [userId] and [targetLanguageCode].
  Future<MissionBrief?> loadBrief({
    required String missionId,
    required String userId,
    required String targetLanguageCode,
    required String explanationLanguageCode,
  });

  /// Retrieves the saved default [MissionMode] for [userId].
  Future<MissionMode> getDefaultMode({required String userId});

  /// Saves the default [MissionMode] for [userId].
  Future<void> saveDefaultMode({
    required String userId,
    required MissionMode mode,
  });

  /// Retrieves the saved default [MissionSupport] for [userId].
  Future<MissionSupport> getDefaultSupport({required String userId});

  /// Saves the default [MissionSupport] for [userId].
  Future<void> saveDefaultSupport({
    required String userId,
    required MissionSupport support,
  });
}

import '../../domain/mission_summary.dart';
import '../../domain/today_mission.dart';

/// DTO representing the response from `GET /api/missions/today`.
class TodayMissionDto {
  const TodayMissionDto({
    required this.missionId,
    required this.title,
    required this.characterName,
    required this.characterRole,
    required this.durationMinutes,
    required this.category,
    required this.icon,
    this.description,
    required this.status,
  });

  final String missionId;
  final String title;
  final String characterName;
  final String characterRole;
  final int durationMinutes;
  final String category;
  final String icon;
  final String? description;
  final String status;

  factory TodayMissionDto.fromJson(Map<String, dynamic> json) {
    final parsed = tryParse(json);
    if (parsed != null) return parsed;

    return TodayMissionDto(
      missionId: json['mission_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      characterName: json['character_name'] as String? ?? '',
      characterRole: json['character_role'] as String? ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 5,
      category: json['category'] as String? ?? 'Everyday',
      icon: json['icon'] as String? ?? '☕',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'not_started',
    );
  }

  /// Safely attempts to parse [TodayMissionDto] handling wrapped keys like
  /// `{"today_mission": null}` or `{"today_mission": {...}}` or flat JSON.
  /// Returns `null` if the mission is null or missing essential title/id.
  static TodayMissionDto? tryParse(Map<String, dynamic> json) {
    var raw = json;
    if (raw.containsKey('today_mission')) {
      final inner = raw['today_mission'];
      if (inner == null) return null;
      if (inner is Map<String, dynamic>) {
        raw = inner;
      } else {
        return null;
      }
    } else if (raw.containsKey('mission') && raw['mission'] is Map<String, dynamic>) {
      raw = raw['mission'] as Map<String, dynamic>;
    } else if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
      raw = raw['data'] as Map<String, dynamic>;
    }

    final missionId = raw['mission_id'] as String? ?? raw['id'] as String? ?? '';
    final title = raw['title'] as String? ?? raw['name'] as String? ?? '';
    if (missionId.isEmpty && title.isEmpty) {
      return null;
    }

    return TodayMissionDto(
      missionId: missionId,
      title: title,
      characterName: raw['character_name'] as String? ?? raw['character'] as String? ?? '',
      characterRole: raw['character_role'] as String? ?? raw['role'] as String? ?? '',
      durationMinutes: (raw['duration_minutes'] as num?)?.toInt() ?? 5,
      category: raw['category'] as String? ?? 'Everyday',
      icon: raw['icon'] as String? ?? raw['emoji'] as String? ?? '☕',
      description: raw['description'] as String?,
      status: raw['status'] as String? ?? 'not_started',
    );
  }

  TodayMission toTodayMission() {
    final parsedStatus = _parseStatus(status);
    final isDone = parsedStatus == MissionStatus.done;

    return TodayMission(
      mission: MissionSummary(
        id: missionId,
        categoryIds: [category.toLowerCase().trim()],
        title: title,
        characterName: characterName,
        characterRole: characterRole,
        durationMinutes: durationMinutes,
        difficulty: 1,
        emoji: icon,
        status: parsedStatus,
      ),
      isCompleted: isDone,
      reason: description ?? 'Daily highlight',
      date: DateTime.now(),
    );
  }

  static MissionStatus _parseStatus(String? raw) {
    final s = raw?.toLowerCase().trim();
    if (s == 'complete' || s == 'completed' || s == 'done') {
      return MissionStatus.done;
    }
    if (s == 'in_progress' || s == 'inprogress') {
      return MissionStatus.inProgress;
    }
    return MissionStatus.newMission;
  }
}


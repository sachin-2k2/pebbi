import '../../domain/mission_category.dart';
import '../../domain/mission_summary.dart';

/// DTO representing the response from `GET /api/missions`.
class MissionsResponseDto {
  const MissionsResponseDto({
    required this.categories,
    required this.missions,
  });

  final List<String> categories;
  final List<MissionItemDto> missions;

  factory MissionsResponseDto.fromJson(Map<String, dynamic> json) {
    var raw = json;
    if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
      raw = raw['data'] as Map<String, dynamic>;
    }

    final rawCats = raw['categories'];
    final catList = (rawCats is List)
        ? rawCats.map((e) => e.toString()).toList()
        : const <String>[];

    final rawMissions = raw['missions'];
    final misList = (rawMissions is List)
        ? rawMissions
            .whereType<Map<String, dynamic>>()
            .map(MissionItemDto.fromJson)
            .where((m) => m.missionId.isNotEmpty || m.title.isNotEmpty)
            .toList()
        : const <MissionItemDto>[];

    return MissionsResponseDto(
      categories: catList,
      missions: misList,
    );
  }

  List<MissionCategory> toCategories() {
    if (categories.isEmpty) {
      return const [MissionCategory(id: 'all', title: 'All')];
    }
    return categories.map((cat) {
      return MissionCategory(
        id: cat.toLowerCase().trim(),
        title: cat,
      );
    }).toList();
  }

  List<MissionSummary> toMissionSummaries() {
    return missions.map((m) => m.toMissionSummary()).toList();
  }
}

/// DTO representing an individual mission item in `GET /api/missions`.
class MissionItemDto {
  const MissionItemDto({
    required this.missionId,
    required this.title,
    required this.characterName,
    required this.characterRole,
    required this.durationMinutes,
    required this.category,
    required this.icon,
    required this.status,
  });

  final String missionId;
  final String title;
  final String characterName;
  final String characterRole;
  final int durationMinutes;
  final String category;
  final String icon;
  final String status;

  factory MissionItemDto.fromJson(Map<String, dynamic> json) {
    return MissionItemDto(
      missionId: json['mission_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      characterName: json['character_name'] as String? ?? json['character'] as String? ?? '',
      characterRole: json['character_role'] as String? ?? json['role'] as String? ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 5,
      category: json['category'] as String? ?? 'Everyday',
      icon: json['icon'] as String? ?? json['emoji'] as String? ?? '☕',
      status: json['status'] as String? ?? 'not_started',
    );
  }

  MissionSummary toMissionSummary() {
    return MissionSummary(
      id: missionId,
      categoryIds: [category.toLowerCase().trim()],
      title: title,
      characterName: characterName,
      characterRole: characterRole,
      durationMinutes: durationMinutes,
      difficulty: 1,
      emoji: icon,
      status: _parseStatus(status),
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


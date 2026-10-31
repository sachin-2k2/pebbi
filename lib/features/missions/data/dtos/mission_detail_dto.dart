import '../../domain/mission_brief.dart';
import '../../domain/mission_goal.dart';
import '../../domain/mission_summary.dart';

/// DTO for `/api/missions/{mission_id}` detail response.
///
/// Follows AGENTS.md §2.1 & §3.1 (<150 lines).
class MissionDetailDto {
  const MissionDetailDto({
    required this.missionId,
    required this.title,
    required this.characterName,
    required this.characterRole,
    required this.durationMinutes,
    required this.category,
    required this.icon,
    this.description,
    this.scene,
    this.goals = const [],
    this.initialCharacterText,
    this.initialTranslation,
    this.status = 'not_started',
  });

  factory MissionDetailDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final rawGoals = data['goals'] as List<dynamic>? ?? const [];
    final goals = rawGoals.map((g) {
      if (g is Map<String, dynamic>) {
        return MissionGoalDto.fromJson(g);
      }
      return MissionGoalDto(id: '0', goal: g.toString());
    }).toList();

    final initMsg = data['initial_message'] as Map<String, dynamic>?;

    return MissionDetailDto(
      missionId: (data['mission_id'] ?? data['id'] ?? '').toString(),
      title: (data['title'] ?? data['name'] ?? '').toString(),
      characterName:
          (data['character_name'] ?? data['character'] ?? '').toString(),
      characterRole: (data['character_role'] ?? data['role'] ?? '').toString(),
      durationMinutes: (data['duration_minutes'] as num?)?.toInt() ?? 5,
      category: (data['category'] ?? 'Everyday').toString(),
      icon: (data['icon'] ?? data['emoji'] ?? '☕').toString(),
      description: data['description']?.toString(),
      scene: data['scene']?.toString(),
      goals: goals,
      initialCharacterText: initMsg?['character_text']?.toString(),
      initialTranslation: initMsg?['translation']?.toString(),
      status: (data['status'] ?? 'not_started').toString(),
    );
  }

  final String missionId;
  final String title;
  final String characterName;
  final String characterRole;
  final int durationMinutes;
  final String category;
  final String icon;
  final String? description;
  final String? scene;
  final List<MissionGoalDto> goals;
  final String? initialCharacterText;
  final String? initialTranslation;
  final String status;

  MissionBrief toMissionBrief({required String targetLanguageCode}) {
    return MissionBrief(
      missionId: missionId,
      emoji: icon,
      title: title,
      characterName: characterName,
      characterRole: characterRole,
      sceneLine: scene ?? description,
      goals: goals.map((g) => g.toMissionGoal()).toList(),
      estimatedMinutes: durationMinutes,
      difficulty: durationMinutes > 5 ? 2 : 1,
      languageCode: targetLanguageCode,
      status: _mapStatus(status),
    );
  }

  static MissionStatus _mapStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'complete':
      case 'completed':
      case 'done':
        return MissionStatus.done;
      case 'in_progress':
      case 'inprogress':
        return MissionStatus.inProgress;
      default:
        return MissionStatus.newMission;
    }
  }
}

/// DTO for a single learning goal inside a mission detail.
class MissionGoalDto {
  const MissionGoalDto({
    required this.id,
    required this.goal,
    this.translatedGoal,
    this.completed = false,
  });

  factory MissionGoalDto.fromJson(Map<String, dynamic> json) {
    return MissionGoalDto(
      id: (json['id'] ?? '').toString(),
      goal: (json['goal'] ?? json['text'] ?? '').toString(),
      translatedGoal: json['translated_goal']?.toString(),
      completed: json['completed'] as bool? ?? false,
    );
  }

  final String id;
  final String goal;
  final String? translatedGoal;
  final bool completed;

  MissionGoal toMissionGoal() {
    return MissionGoal(
      id: id.isNotEmpty ? id : goal,
      text: goal,
    );
  }
}


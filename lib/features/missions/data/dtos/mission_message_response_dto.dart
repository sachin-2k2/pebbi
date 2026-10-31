/// DTO for `/api/missions/{mission_id}/message` response.
///
/// Follows AGENTS.md §2.1 & §3.1 (<150 lines).
class MissionMessageResponseDto {
  const MissionMessageResponseDto({
    required this.characterText,
    this.translation,
    this.completedGoals = const [],
    this.isFinished = false,
  });

  factory MissionMessageResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final rawGoals = data['completed_goals'] as List<dynamic>? ?? const [];
    final goals = rawGoals.map((g) => g.toString()).toList();

    return MissionMessageResponseDto(
      characterText: (data['character_text'] ??
              data['reply'] ??
              data['message'] ??
              '')
          .toString(),
      translation: (data['translation'] ?? data['translated_text'])?.toString(),
      completedGoals: goals,
      isFinished: data['is_finished'] as bool? ?? false,
    );
  }

  final String characterText;
  final String? translation;
  final List<String> completedGoals;
  final bool isFinished;
}


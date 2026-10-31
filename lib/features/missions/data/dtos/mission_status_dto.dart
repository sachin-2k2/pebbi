/// DTO representing the response from start or complete mission calls:
/// - `POST /api/missions/{mission_id}/start`
/// - `POST /api/missions/{mission_id}/complete`
class MissionStatusDto {
  const MissionStatusDto({
    required this.missionId,
    required this.status,
  });

  final String missionId;
  final String status;

  factory MissionStatusDto.fromJson(Map<String, dynamic> json) {
    return MissionStatusDto(
      missionId: json['mission_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}


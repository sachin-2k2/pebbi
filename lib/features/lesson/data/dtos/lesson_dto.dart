/// Provisional DTOs representing remote lesson data from the backend.
///
/// Follows AGENTS.md §2.1: DTOs in data/ layer, provisional until backend API docs arrive.
class LessonItemDto {
  const LessonItemDto({
    required this.id,
    required this.type,
    required this.payload,
  });

  final String id;
  final String type;
  final Map<String, dynamic> payload;

  factory LessonItemDto.fromJson(Map<String, dynamic> json) {
    return LessonItemDto(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      payload: (json['payload'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'payload': payload};
}

class LessonDto {
  const LessonDto({
    required this.id,
    required this.stopId,
    required this.title,
    required this.items,
  });

  final String id;
  final String stopId;
  final String title;
  final List<LessonItemDto> items;

  factory LessonDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return LessonDto(
      id: json['id'] as String? ?? '',
      stopId: json['stopId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      items: rawItems
          .map((e) => LessonItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'stopId': stopId,
    'title': title,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

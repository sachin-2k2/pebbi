import '../../domain/track.dart';

/// DTO representing a course track from `GET /api/tracks`.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class TrackDto {
  const TrackDto({
    required this.trackId,
    required this.title,
    required this.description,
    required this.icon,
    required this.totalLessons,
    this.isRecommended = false,
  });

  final String trackId;
  final String title;
  final String description;
  final String icon;
  final int totalLessons;
  final bool isRecommended;

  factory TrackDto.fromJson(Map<String, dynamic> json) {
    return TrackDto(
      trackId: json['track_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '🌍',
      totalLessons: (json['total_lessons'] as num?)?.toInt() ?? 0,
      isRecommended: json['is_recommended'] == true,
    );
  }

  /// Converts this DTO to a domain [Track] entity.
  Track toDomain() {
    return Track(
      id: trackId,
      title: title,
      emoji: icon,
      hasContent: totalLessons > 0,
      isRecommended: isRecommended,
      description: description,
    );
  }
}

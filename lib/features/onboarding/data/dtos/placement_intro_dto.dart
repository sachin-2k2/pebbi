import '../../domain/placement_intro.dart';

/// Tolerant DTO for `GET /api/placement/intro`.
class PlacementIntroDto {
  const PlacementIntroDto({
    required this.pebbiSays,
    required this.subtitle,
    this.nativeLanguage,
    this.targetLanguage,
    this.title,
    this.estimatedMinutes,
  });

  final String pebbiSays;
  final String subtitle;
  final String? nativeLanguage;
  final String? targetLanguage;
  final String? title;
  final int? estimatedMinutes;

  factory PlacementIntroDto.fromJson(Map<String, dynamic> json) {
    return PlacementIntroDto(
      pebbiSays:
          json['pebbi_says']?.toString() ?? json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      nativeLanguage: json['native_language']?.toString(),
      targetLanguage: json['target_language']?.toString(),
      title: json['title']?.toString() ?? json['pebbi_says']?.toString(),
      estimatedMinutes: json['estimated_minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'pebbi_says': pebbiSays,
    'subtitle': subtitle,
    'native_language': nativeLanguage,
    'target_language': targetLanguage,
    'title': title,
    'estimated_minutes': estimatedMinutes,
  };

  PlacementIntro toDomain() => PlacementIntro(
    pebbiSays: pebbiSays,
    subtitle: subtitle,
    nativeLanguage: nativeLanguage,
    targetLanguage: targetLanguage,
    title: title,
    estimatedMinutes: estimatedMinutes,
  );
}

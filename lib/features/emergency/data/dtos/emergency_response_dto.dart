import '../../domain/emergency_phrasebook.dart';
import 'emergency_phrase_dto.dart';

/// DTO for the `/api/missions/emergency` response payload.
///
/// Follows AGENTS.md §2.1 & §3.1 (<150 lines).
class EmergencyResponseDto {
  const EmergencyResponseDto({
    this.title,
    this.subtitle,
    this.disclaimer,
    this.learningLanguage,
    this.phrases = const [],
  });

  factory EmergencyResponseDto.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawPhrases = root['phrases'] as List<dynamic>? ?? const [];
    final phrases = rawPhrases
        .whereType<Map<String, dynamic>>()
        .map(EmergencyPhraseDto.fromJson)
        .toList();

    return EmergencyResponseDto(
      title: root['title']?.toString(),
      subtitle: root['subtitle']?.toString(),
      disclaimer: root['disclaimer']?.toString(),
      learningLanguage: root['learning_language']?.toString(),
      phrases: phrases,
    );
  }

  final String? title;
  final String? subtitle;
  final String? disclaimer;
  final String? learningLanguage;
  final List<EmergencyPhraseDto> phrases;

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (subtitle != null) 'subtitle': subtitle,
    if (disclaimer != null) 'disclaimer': disclaimer,
    if (learningLanguage != null) 'learning_language': learningLanguage,
    'phrases': phrases.map((p) => p.toJson()).toList(),
  };

  /// Converts this DTO into domain model [EmergencyPhrasebook].
  EmergencyPhrasebook toDomain({
    required String targetLanguageCode,
    required String explanationLanguageCode,
  }) {
    return EmergencyPhrasebook(
      languageCode: targetLanguageCode,
      languageName: learningLanguage ?? 'Spanish',
      isReviewed: true,
      title: title,
      subtitle: subtitle,
      disclaimer: disclaimer,
      phrases: phrases
          .map(
            (p) => p.toDomain(
              targetLanguageCode: targetLanguageCode,
              explanationLanguageCode: explanationLanguageCode,
            ),
          )
          .toList(),
    );
  }
}


import '../../domain/emergency_phrase.dart';

/// DTO for an emergency phrase item in `/api/missions/emergency`.
///
/// Follows AGENTS.md §2.1 & §3.1 (<150 lines).
class EmergencyPhraseDto {
  const EmergencyPhraseDto({
    required this.phraseId,
    required this.nativeText,
    required this.translation,
  });

  factory EmergencyPhraseDto.fromJson(Map<String, dynamic> json) {
    return EmergencyPhraseDto(
      phraseId: (json['phrase_id'] ?? json['id'] ?? '').toString(),
      nativeText: (json['native_text'] ?? json['text'] ?? '').toString(),
      translation: (json['translation'] ?? json['translated'] ?? '').toString(),
    );
  }

  final String phraseId;
  final String nativeText;
  final String translation;

  Map<String, dynamic> toJson() => {
    'phrase_id': phraseId,
    'native_text': nativeText,
    'translation': translation,
  };

  /// Converts this DTO into domain model [EmergencyPhrase].
  EmergencyPhrase toDomain({
    required String targetLanguageCode,
    required String explanationLanguageCode,
  }) {
    return EmergencyPhrase(
      id: phraseId,
      labels: {
        explanationLanguageCode: nativeText,
        'en': nativeText,
      },
      targetText: translation,
      ttsLocale: targetLanguageCode,
    );
  }
}


import '../../domain/language_option.dart';
import '../../domain/learnable_language.dart';

/// DTO for native / explanation language from GET /api/languages/native.
class NativeLanguageDto {
  const NativeLanguageDto({
    required this.code,
    required this.name,
    required this.englishName,
    required this.scriptGlyph,
    required this.translationsReviewed,
  });

  final String code;
  final String name;
  final String englishName;
  final String scriptGlyph;
  final bool translationsReviewed;

  factory NativeLanguageDto.fromJson(Map<String, dynamic> json) {
    return NativeLanguageDto(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      englishName: json['english_name']?.toString() ?? '',
      scriptGlyph: json['script_glyph']?.toString() ?? '',
      translationsReviewed: json['translations_reviewed'] as bool? ?? false,
    );
  }

  LanguageOption toDomain() {
    return LanguageOption(
      code: code,
      nativeName: name,
      englishName: englishName,
      badgeGlyph: scriptGlyph,
      translationsReviewed: translationsReviewed,
      isRtl: code == 'ar' || code == 'ur' || code == 'fa' || code == 'he',
    );
  }
}

/// DTO for learnable language from GET /api/languages/learn.
class LearnLanguageDto {
  const LearnLanguageDto({
    required this.code,
    required this.name,
    required this.englishName,
    required this.scriptGlyph,
    required this.learnersCount,
    required this.status,
    required this.hasLessons,
    required this.hasPlacement,
    required this.helloText,
    required this.ttsLocale,
    this.difficulty,
  });

  final String code;
  final String name;
  final String englishName;
  final String scriptGlyph;
  final int? difficulty;
  final int learnersCount;
  final String status;
  final bool hasLessons;
  final bool hasPlacement;
  final String helloText;
  final String ttsLocale;

  factory LearnLanguageDto.fromJson(Map<String, dynamic> json) {
    return LearnLanguageDto(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      englishName: json['english_name']?.toString() ?? '',
      scriptGlyph: json['script_glyph']?.toString() ?? '',
      difficulty: (json['difficulty'] as num?)?.toInt(),
      learnersCount: (json['learners_count'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'coming_soon',
      hasLessons: json['has_lessons'] as bool? ?? false,
      hasPlacement: json['has_placement'] as bool? ?? false,
      helloText: json['hello_text']?.toString() ?? '',
      ttsLocale: json['tts_locale']?.toString() ?? 'en-US',
    );
  }

  LearnableLanguage toDomain() {
    final isSelectable = status == 'available' && hasLessons;
    return LearnableLanguage(
      code: code,
      nativeName: name,
      englishName: englishName,
      glyph: scriptGlyph,
      difficulty: difficulty,
      learnersCount: learnersCount,
      isAvailable: isSelectable,
      status: status,
      hasLessons: hasLessons,
      hasPlacement: hasPlacement,
      helloText: helloText,
      ttsLocale: ttsLocale,
    );
  }
}

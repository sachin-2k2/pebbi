import '../domain/language_option.dart';
import '../domain/language_repository.dart';

/// Mock implementation of [LanguageRepository] providing the 9 explanation languages.
///
/// Follows AGENTS.md §1 & §2.1: Mock repository with realistic sample data.
/// Can be cleanly swapped when the backend team provides the real API.
class MockLanguageRepository implements LanguageRepository {
  const MockLanguageRepository();

  static const List<LanguageOption> defaultLanguages = [
    LanguageOption(
      code: 'en',
      nativeName: 'English',
      englishName: 'English',
      badgeGlyph: 'A',
      translationsReviewed: true,
    ),
    LanguageOption(
      code: 'ar',
      nativeName: 'العربية',
      englishName: 'Arabic',
      badgeGlyph: 'ع',
      translationsReviewed: false,
      isRtl: true,
    ),
    LanguageOption(
      code: 'hi',
      nativeName: 'हिन्दी',
      englishName: 'Hindi',
      badgeGlyph: 'अ',
      translationsReviewed: false,
    ),
    LanguageOption(
      code: 'ml',
      nativeName: 'മലയാളം',
      englishName: 'Malayalam',
      badgeGlyph: 'മ',
      translationsReviewed: false,
    ),
    LanguageOption(
      code: 'es',
      nativeName: 'Español',
      englishName: 'Spanish',
      badgeGlyph: 'É',
      translationsReviewed: false,
    ),
    LanguageOption(
      code: 'ur',
      nativeName: 'اردو',
      englishName: 'Urdu',
      badgeGlyph: 'ی',
      translationsReviewed: false,
      isRtl: true,
    ),
    LanguageOption(
      code: 'fr',
      nativeName: 'Français',
      englishName: 'French',
      badgeGlyph: 'Ê',
      translationsReviewed: false,
    ),
    LanguageOption(
      code: 'pt',
      nativeName: 'Português',
      englishName: 'Portuguese',
      badgeGlyph: 'Ç',
      translationsReviewed: false,
    ),
    LanguageOption(
      code: 'id',
      nativeName: 'Bahasa Indonesia',
      englishName: 'Indonesian',
      badgeGlyph: 'I',
      translationsReviewed: false,
    ),
  ];

  @override
  List<LanguageOption> getExplanationLanguages() => defaultLanguages;
}

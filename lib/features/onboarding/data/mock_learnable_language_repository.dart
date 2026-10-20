import '../domain/learnable_language.dart';
import '../domain/learnable_language_repository.dart';

/// Mock repository implementation returning the 10 catalog languages for Step 4.
///
/// Follows AGENTS.md §1 & §2: realistic mock data matching the UI specification.
class MockLearnableLanguageRepository implements LearnableLanguageRepository {
  const MockLearnableLanguageRepository();

  static const List<LearnableLanguage> _languages = [
    // --- Available (5) ---
    LearnableLanguage(
      code: 'es',
      nativeName: 'Español',
      englishName: 'Spanish',
      glyph: 'Ñ',
      difficulty: 1,
      learnersCount: 42000000,
      isAvailable: true,
      helloText: '¡Hola!',
      ttsLocale: 'es-ES',
    ),
    LearnableLanguage(
      code: 'fr',
      nativeName: 'Français',
      englishName: 'French',
      glyph: 'É',
      difficulty: 1,
      learnersCount: 28000000,
      isAvailable: true,
      helloText: 'Bonjour !',
      ttsLocale: 'fr-FR',
    ),
    LearnableLanguage(
      code: 'de',
      nativeName: 'Deutsch',
      englishName: 'German',
      glyph: 'ß',
      difficulty: 2,
      learnersCount: 19000000,
      isAvailable: true,
      helloText: 'Hallo!',
      ttsLocale: 'de-DE',
    ),
    LearnableLanguage(
      code: 'ja',
      nativeName: '日本語',
      englishName: 'Japanese',
      glyph: 'あ',
      difficulty: 3,
      learnersCount: 17000000,
      isAvailable: true,
      helloText: 'こんにちは',
      ttsLocale: 'ja-JP',
    ),
    LearnableLanguage(
      code: 'ar',
      nativeName: 'العربية',
      englishName: 'Arabic',
      glyph: 'ع',
      difficulty: 3,
      learnersCount: 14000000,
      isAvailable: true,
      helloText: 'مرحبًا',
      ttsLocale: 'ar-SA',
    ),

    // --- Coming Soon (5) ---
    LearnableLanguage(
      code: 'hi',
      nativeName: 'हिन्दी',
      englishName: 'Hindi',
      glyph: 'अ',
      difficulty: null,
      learnersCount: 12000000,
      isAvailable: false,
      helloText: 'नमस्ते',
      ttsLocale: 'hi-IN',
    ),
    LearnableLanguage(
      code: 'ko',
      nativeName: '한국어',
      englishName: 'Korean',
      glyph: '한',
      difficulty: null,
      learnersCount: 11000000,
      isAvailable: false,
      helloText: '안녕하세요',
      ttsLocale: 'ko-KR',
    ),
    LearnableLanguage(
      code: 'zh',
      nativeName: '中文',
      englishName: 'Mandarin Chinese',
      glyph: '你',
      difficulty: null,
      learnersCount: 16000000,
      isAvailable: false,
      helloText: '你好',
      ttsLocale: 'zh-CN',
    ),
    LearnableLanguage(
      code: 'pt',
      nativeName: 'Português',
      englishName: 'Portuguese (Brazil)',
      glyph: 'Ã',
      difficulty: null,
      learnersCount: 9000000,
      isAvailable: false,
      helloText: 'Olá!',
      ttsLocale: 'pt-BR',
    ),
    LearnableLanguage(
      code: 'en',
      nativeName: 'English',
      englishName: 'English',
      glyph: 'A',
      difficulty: null,
      learnersCount: 60000000,
      isAvailable: false,
      helloText: 'Hello!',
      ttsLocale: 'en-US',
    ),
  ];

  @override
  List<LearnableLanguage> getLearnableLanguages() => _languages;
}

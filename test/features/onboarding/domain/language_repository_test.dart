import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/data/mock_language_repository.dart';
import 'package:peddi/features/onboarding/domain/onboarding_state.dart';

void main() {
  group('LanguageRepository & LanguageOption Domain Tests', () {
    const repository = MockLanguageRepository();

    test('returns exactly 9 languages with correct configurations', () {
      final languages = repository.getExplanationLanguages();
      expect(languages.length, equals(9));

      // English is the only reviewed language at launch
      final english = languages.firstWhere((l) => l.code == 'en');
      expect(english.translationsReviewed, isTrue);
      expect(english.isRtl, isFalse);
      expect(english.badgeGlyph, equals('A'));

      final nonEnglish = languages.where((l) => l.code != 'en');
      for (final lang in nonEnglish) {
        expect(
          lang.translationsReviewed,
          isFalse,
          reason:
              '${lang.englishName} should have translationsReviewed == false',
        );
      }

      // Arabic and Urdu are RTL
      final arabic = languages.firstWhere((l) => l.code == 'ar');
      expect(arabic.isRtl, isTrue);
      expect(arabic.badgeGlyph, equals('ع'));

      final urdu = languages.firstWhere((l) => l.code == 'ur');
      expect(urdu.isRtl, isTrue);
      expect(urdu.badgeGlyph, equals('ی'));
    });

    test('matches search query ignoring case and diacritics / accents', () {
      final languages = repository.getExplanationLanguages();
      final spanish = languages.firstWhere((l) => l.code == 'es');
      final french = languages.firstWhere((l) => l.code == 'fr');

      // Accent stripping
      expect(spanish.matches('espanol'), isTrue);
      expect(spanish.matches('ESPANOL'), isTrue);
      expect(spanish.matches('Español'), isTrue);
      expect(spanish.matches('spanish'), isTrue);

      expect(french.matches('francais'), isTrue);
      expect(french.matches('Français'), isTrue);
      expect(french.matches('french'), isTrue);

      // Non-matching
      expect(spanish.matches('deutsch'), isFalse);
    });

    test('OnboardingState holds explanationLanguageCode defaulting to en', () {
      const state = OnboardingState();
      expect(state.explanationLanguageCode, equals('en'));

      final updated = state.copyWith(explanationLanguageCode: 'es');
      expect(updated.explanationLanguageCode, equals('es'));
    });
  });
}

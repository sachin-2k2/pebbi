import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/data/mock_learnable_language_repository.dart';
import 'package:peddi/features/onboarding/domain/onboarding_state.dart';
import 'package:peddi/features/onboarding/presentation/widgets/learners_caption.dart';

void main() {
  group('MockLearnableLanguageRepository Unit Tests', () {
    const repository = MockLearnableLanguageRepository();

    test('returns exactly 10 languages (5 available, 5 coming soon)', () {
      final languages = repository.getLearnableLanguages();
      expect(languages.length, equals(10));

      final available = languages.where((l) => l.isAvailable).toList();
      final comingSoon = languages.where((l) => !l.isAvailable).toList();

      expect(available.length, equals(5));
      expect(comingSoon.length, equals(5));
    });

    test('available languages have valid difficulty between 1 and 3', () {
      final languages = repository.getLearnableLanguages();
      final available = languages.where((l) => l.isAvailable);

      for (final lang in available) {
        expect(lang.difficulty, isNotNull);
        expect(lang.difficulty!, inInclusiveRange(1, 3));
        expect(lang.helloText.isNotEmpty, isTrue);
        expect(lang.ttsLocale.isNotEmpty, isTrue);
      }
    });

    test('coming soon languages have null difficulty', () {
      final languages = repository.getLearnableLanguages();
      final comingSoon = languages.where((l) => !l.isAvailable);

      for (final lang in comingSoon) {
        expect(lang.difficulty, isNull);
        expect(lang.isAvailable, isFalse);
      }
    });

    test('all languages have unique non-empty codes and glyphs', () {
      final languages = repository.getLearnableLanguages();
      final codes = languages.map((l) => l.code).toSet();
      final glyphs = languages.map((l) => l.glyph).toSet();

      expect(codes.length, equals(10));
      expect(glyphs.length, equals(10));
    });

    test('LearnersCaption formatCompact formats correctly', () {
      expect(LearnersCaption.formatCompact(42000000), equals('42M'));
      expect(LearnersCaption.formatCompact(28000000), equals('28M'));
      expect(LearnersCaption.formatCompact(9000000), equals('9M'));
      expect(LearnersCaption.formatCompact(1500000), equals('1.5M'));
      expect(LearnersCaption.formatCompact(500000), equals('500K'));
      expect(LearnersCaption.formatCompact(800), equals('800'));
    });

    test('OnboardingState targetLanguageCode defaults to "es" and updates', () {
      const state = OnboardingState();
      expect(state.targetLanguageCode, equals('es'));

      final updated = state.copyWith(targetLanguageCode: 'ja');
      expect(updated.targetLanguageCode, equals('ja'));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/lesson/domain/speaking_config.dart';
import 'package:peddi/features/lesson/domain/speech_matcher.dart';

void main() {
  group('SpeechMatcher', () {
    test('exact match returns true with 1.0 similarity', () {
      const target = 'Muy bien, gracias';
      const hypothesis = 'Muy bien, gracias';

      expect(SpeechMatcher.isMatch(target: target, hypothesis: hypothesis), isTrue);
      expect(
        SpeechMatcher.similarityScore(target: target, hypothesis: hypothesis),
        equals(1.0),
      );
    });

    test('ignores punctuation including Spanish inverted marks and commas', () {
      const target = '¿Cómo estás?';
      const hypothesis = 'como estas';

      expect(
        SpeechMatcher.isMatch(
          target: target,
          hypothesis: hypothesis,
          locale: 'es-ES',
        ),
        isTrue,
      );
    });

    test('ignores accents when ignoreAccents is true', () {
      const target = 'está delicioso';
      const hypothesis = 'esta delicioso';

      expect(
        SpeechMatcher.isMatch(
          target: target,
          hypothesis: hypothesis,
          ignoreAccents: true,
        ),
        isTrue,
      );
    });

    test('normalizes Arabic diacritics (tashkeel) and alef forms', () {
      const target = 'مَرْحَبًا، كَيْفَ حَالُكَ؟';
      const hypothesis = 'مرحبا كيف حالك';

      expect(
        SpeechMatcher.isMatch(
          target: target,
          hypothesis: hypothesis,
          locale: 'ar-SA',
        ),
        isTrue,
      );
    });

    test('handles space-less scripts like Japanese correctly', () {
      const target = 'こんにちは、元気ですか？';
      const hypothesis = 'こんにちは元気ですか';

      expect(
        SpeechMatcher.isMatch(
          target: target,
          hypothesis: hypothesis,
          locale: 'ja-JP',
        ),
        isTrue,
      );
    });

    test('rejects completely unrelated phrases', () {
      const target = 'Muy bien, gracias';
      const hypothesis = 'Hasta luego y buenas noches';

      expect(SpeechMatcher.isMatch(target: target, hypothesis: hypothesis), isFalse);
      expect(
        SpeechMatcher.similarityScore(target: target, hypothesis: hypothesis),
        lessThan(SpeakingConfig.similarityThreshold),
      );
    });

    test('handles empty hypothesis safely without crash', () {
      const target = 'Muy bien, gracias';
      const hypothesis = '';

      expect(SpeechMatcher.isMatch(target: target, hypothesis: hypothesis), isFalse);
      expect(
        SpeechMatcher.similarityScore(target: target, hypothesis: hypothesis),
        equals(0.0),
      );
    });

    test('handles empty target safely', () {
      expect(SpeechMatcher.isMatch(target: '', hypothesis: ''), isTrue);
      expect(SpeechMatcher.isMatch(target: '', hypothesis: 'hello'), isFalse);
    });

    test('respects custom similarity threshold', () {
      const target = 'buenos dias';
      const hypothesis = 'buenos tardes'; // 1 of 2 tokens match

      expect(
        SpeechMatcher.isMatch(
          target: target,
          hypothesis: hypothesis,
          threshold: 0.90,
        ),
        isFalse,
      );
      expect(
        SpeechMatcher.isMatch(
          target: target,
          hypothesis: hypothesis,
          threshold: 0.40,
        ),
        isTrue,
      );
    });
  });
}

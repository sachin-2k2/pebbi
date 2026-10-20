import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/emergency/data/bundled_emergency_repository.dart';

void main() {
  group('BundledEmergencyRepository (Strictly Offline)', () {
    late BundledEmergencyRepository repository;

    setUp(() {
      repository = BundledEmergencyRepository();
    });

    test(
      'retrieves Spanish emergency phrasebook with 8 reviewed phrases',
      () async {
        final phrasebook = await repository.getPhrasebook(
          targetLanguageCode: 'es',
        );

        expect(phrasebook, isNotNull);
        expect(phrasebook!.languageCode, equals('es'));
        expect(phrasebook.languageName, equals('Spanish'));
        expect(phrasebook.isReviewed, isTrue);
        expect(phrasebook.phrases.length, equals(8));

        // Verify the 8 core emergency phrase IDs from design
        const expectedIds = [
          'need_doctor',
          'call_police',
          'lost',
          'allergic',
          'dont_understand',
          'where_hospital',
          'speak_slowly',
          'lost_passport',
        ];
        expect(
          phrasebook.phrases.map((p) => p.id).toList(),
          equals(expectedIds),
        );
      },
    );

    test('retrieves all 5 core languages with strict ID parity', () async {
      final languages = ['es', 'fr', 'de', 'ja', 'ar'];
      const expectedIds = [
        'need_doctor',
        'call_police',
        'lost',
        'allergic',
        'dont_understand',
        'where_hospital',
        'speak_slowly',
        'lost_passport',
      ];

      for (final lang in languages) {
        final phrasebook = await repository.getPhrasebook(
          targetLanguageCode: lang,
        );
        expect(phrasebook, isNotNull, reason: 'Failed for language $lang');
        expect(phrasebook!.phrases.length, equals(8));
        expect(
          phrasebook.phrases.map((p) => p.id).toList(),
          equals(expectedIds),
        );
      }
    });

    test('marks unreviewed language stubs with isReviewed == false', () async {
      final unreviewedLanguages = ['fr', 'de', 'ja', 'ar'];

      for (final lang in unreviewedLanguages) {
        final phrasebook = await repository.getPhrasebook(
          targetLanguageCode: lang,
        );
        expect(phrasebook, isNotNull);
        expect(
          phrasebook!.isReviewed,
          isFalse,
          reason:
              'Language $lang must be marked unreviewed until human certified',
        );
      }
    });

    test('returns null for unknown language code', () async {
      final phrasebook = await repository.getPhrasebook(
        targetLanguageCode: 'xyz',
      );
      expect(phrasebook, isNull);
    });
  });
}

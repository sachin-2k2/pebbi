import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/emergency/domain/emergency_phrase.dart';
import 'package:peddi/features/emergency/domain/emergency_phrasebook.dart';

void main() {
  group('EmergencyPhrase Domain Model', () {
    const testPhrase = EmergencyPhrase(
      id: 'help',
      targetText: '¡Ayuda!',
      ttsLocale: 'es-ES',
      labels: {'en': 'Help!', 'es': '¡Ayuda!', 'ja': '助けて！'},
      helperLine: 'ah-YOO-dah',
    );

    test('getLabel returns matching explanation language label', () {
      expect(testPhrase.getLabel('ja'), equals('助けて！'));
      expect(testPhrase.getLabel('es'), equals('¡Ayuda!'));
      expect(testPhrase.getLabel('en'), equals('Help!'));
    });

    test('getLabel falls back to English when requested code is missing', () {
      expect(testPhrase.getLabel('de'), equals('Help!'));
      expect(testPhrase.getLabel('fr'), equals('Help!'));
    });

    test(
      'getLabel falls back to first available or targetText if English is missing',
      () {
        const phraseNoEn = EmergencyPhrase(
          id: 'help',
          targetText: 'Aide!',
          ttsLocale: 'fr-FR',
          labels: {'fr': 'Au secours!'},
        );
        expect(phraseNoEn.getLabel('de'), equals('Au secours!'));

        const phraseEmptyLabels = EmergencyPhrase(
          id: 'help',
          targetText: 'Aide!',
          ttsLocale: 'fr-FR',
          labels: {},
        );
        expect(phraseEmptyLabels.getLabel('de'), equals('Aide!'));
      },
    );

    test('equality and hashCode verify value semantics', () {
      const copyPhrase = EmergencyPhrase(
        id: 'help',
        targetText: '¡Ayuda!',
        ttsLocale: 'es-ES',
        labels: {'en': 'Help!', 'es': '¡Ayuda!', 'ja': '助けて！'},
        helperLine: 'ah-YOO-dah',
      );

      expect(testPhrase, equals(copyPhrase));
      expect(testPhrase.hashCode, equals(copyPhrase.hashCode));
    });
  });

  group('EmergencyPhrasebook Domain Model', () {
    test('equality and hashcode match on values', () {
      const book1 = EmergencyPhrasebook(
        languageCode: 'es',
        languageName: 'Spanish',
        phrases: [],
        isReviewed: true,
      );

      const book2 = EmergencyPhrasebook(
        languageCode: 'es',
        languageName: 'Spanish',
        phrases: [],
        isReviewed: true,
      );

      expect(book1, equals(book2));
      expect(book1.hashCode, equals(book2.hashCode));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/emergency/data/dtos/emergency_phrase_dto.dart';
import 'package:peddi/features/emergency/data/dtos/emergency_response_dto.dart';

void main() {
  group('EmergencyPhraseDto Tests', () {
    const rawPhraseJson = {
      'phrase_id': 'need-a-doctor',
      'native_text': 'I need a doctor',
      'translation': 'Necesito un médico',
    };

    test('fromJson parses phrase fields correctly', () {
      final dto = EmergencyPhraseDto.fromJson(rawPhraseJson);

      expect(dto.phraseId, equals('need-a-doctor'));
      expect(dto.nativeText, equals('I need a doctor'));
      expect(dto.translation, equals('Necesito un médico'));
    });

    test('toJson serializes phrase fields correctly', () {
      final dto = EmergencyPhraseDto.fromJson(rawPhraseJson);
      final json = dto.toJson();

      expect(json['phrase_id'], equals('need-a-doctor'));
      expect(json['native_text'], equals('I need a doctor'));
      expect(json['translation'], equals('Necesito un médico'));
    });

    test('toDomain maps to EmergencyPhrase with labels and ttsLocale', () {
      final dto = EmergencyPhraseDto.fromJson(rawPhraseJson);
      final domain = dto.toDomain(
        targetLanguageCode: 'es',
        explanationLanguageCode: 'en',
      );

      expect(domain.id, equals('need-a-doctor'));
      expect(domain.targetText, equals('Necesito un médico'));
      expect(domain.ttsLocale, equals('es'));
      expect(domain.getLabel('en'), equals('I need a doctor'));
    });
  });

  group('EmergencyResponseDto Tests', () {
    const rawResponseJson = {
      'title': 'Emergency phrasebook',
      'subtitle': 'Tap a card, then show your screen. Works with no connection.',
      'disclaimer': "Phrases are for the language you're learning (Spanish).",
      'learning_language': 'Spanish',
      'phrases': [
        {
          'phrase_id': 'need-a-doctor',
          'native_text': 'I need a doctor',
          'translation': 'Necesito un médico',
        },
        {
          'phrase_id': 'call-the-police',
          'native_text': 'Call the police',
          'translation': 'Llame a la policía, por favor',
        },
      ],
    };

    test('fromJson parses response fields and nested phrases', () {
      final dto = EmergencyResponseDto.fromJson(rawResponseJson);

      expect(dto.title, equals('Emergency phrasebook'));
      expect(dto.subtitle, contains('Tap a card'));
      expect(dto.disclaimer, contains('Spanish'));
      expect(dto.learningLanguage, equals('Spanish'));
      expect(dto.phrases.length, equals(2));
      expect(dto.phrases.first.phraseId, equals('need-a-doctor'));
    });

    test('fromJson handles wrapped data envelope', () {
      final wrapped = {'data': rawResponseJson};
      final dto = EmergencyResponseDto.fromJson(wrapped);

      expect(dto.title, equals('Emergency phrasebook'));
      expect(dto.phrases.length, equals(2));
    });

    test('toDomain maps to EmergencyPhrasebook correctly', () {
      final dto = EmergencyResponseDto.fromJson(rawResponseJson);
      final phrasebook = dto.toDomain(
        targetLanguageCode: 'es',
        explanationLanguageCode: 'en',
      );

      expect(phrasebook.languageCode, equals('es'));
      expect(phrasebook.languageName, equals('Spanish'));
      expect(phrasebook.isReviewed, isTrue);
      expect(phrasebook.title, equals('Emergency phrasebook'));
      expect(phrasebook.phrases.length, equals(2));
      expect(phrasebook.phrases.first.targetText, equals('Necesito un médico'));
    });
  });
}


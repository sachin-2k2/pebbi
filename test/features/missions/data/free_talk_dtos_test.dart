import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/missions/data/dtos/free_talk_dtos.dart';

void main() {
  group('FreeTalk DTO Tests', () {
    test('FreeTalkStartResponseDto parses start payload correctly', () {
      const json = {
        'session_id': '6724a1b8c4d29e3a89012345',
        'character_name': 'Pebbi',
        'character_role': 'a friendly conversation partner',
        'scene': 'Anywhere you like',
        'topic': 'Food',
        'correction_style': 'gentle',
        'goals': [
          {'id': 1, 'goal': 'Keep the conversation going', 'completed': false},
          {'id': 2, 'goal': 'Ask one question back', 'completed': false},
          {'id': 3, 'goal': 'Use a phrase you just learned', 'completed': false},
        ],
        'initial_message': {
          'character_text': '¡Hola! Hoy me encantaría hablar de comida.',
          'translation': 'Hello! Today I would love to talk about food.',
        },
        'options': [
          {
            'text': 'Me encanta la pizza y la pasta.',
            'translation': 'I love pizza and pasta.',
          },
        ],
      };

      final dto = FreeTalkStartResponseDto.fromJson(json);

      expect(dto.sessionId, equals('6724a1b8c4d29e3a89012345'));
      expect(dto.characterName, equals('Pebbi'));
      expect(dto.topic, equals('Food'));
      expect(dto.correctionStyle, equals('gentle'));
      expect(dto.goals.length, equals(3));
      expect(dto.goals.first.id, equals('1'));
      expect(dto.goals.first.goal, equals('Keep the conversation going'));
      expect(dto.initialMessage.characterText, equals('¡Hola! Hoy me encantaría hablar de comida.'));
      expect(dto.options.length, equals(1));
      expect(dto.options.first.text, equals('Me encanta la pizza y la pasta.'));
    });

    test('FreeTalkMessageResponseDto parses turn response correctly', () {
      const json = {
        'character_text': '¡La pizza es deliciosa!',
        'translation': 'Pizza is delicious!',
        'live_correction': '💡 Tip: Say "Me gusta" instead of "Yo gusta"',
        'completed_goals': ['Keep the conversation going'],
        'is_finished': false,
        'options': [
          {'text': '¿Cuál es tu pizza favorita?', 'translation': 'What is your favorite pizza?'},
        ],
      };

      final dto = FreeTalkMessageResponseDto.fromJson(json);

      expect(dto.characterText, equals('¡La pizza es deliciosa!'));
      expect(dto.translation, equals('Pizza is delicious!'));
      expect(dto.liveCorrection, equals('💡 Tip: Say "Me gusta" instead of "Yo gusta"'));
      expect(dto.completedGoals, equals(['Keep the conversation going']));
      expect(dto.isFinished, isFalse);
      expect(dto.options.length, equals(1));
    });

    test('FreeTalkDebriefResponseDto parses debrief response correctly', () {
      const json = {
        'topic': 'Food',
        'completed_goals': [
          'Keep the conversation going',
          'Ask one question back',
        ],
        'total_messages': 6,
        'debrief': {
          'praise': 'Great job! You maintained a smooth conversation.',
          'corrections': [
            {
              'user_said': 'Yo gusta pizza',
              'better_way': 'Me gusta la pizza',
              'explanation': 'In Spanish, we use "me gusta".',
            },
          ],
          'vocabulary_recap': ['plato favorito', 'ingredientes'],
        },
      };

      final dto = FreeTalkDebriefResponseDto.fromJson(json);

      expect(dto.topic, equals('Food'));
      expect(dto.completedGoals.length, equals(2));
      expect(dto.totalMessages, equals(6));
      expect(dto.debrief, isNotNull);
      expect(dto.debrief!.praise, contains('Great job!'));
      expect(dto.debrief!.corrections.length, equals(1));
      expect(dto.debrief!.corrections.first.userSaid, equals('Yo gusta pizza'));
      expect(dto.debrief!.corrections.first.betterWay, equals('Me gusta la pizza'));
      expect(dto.debrief!.vocabularyRecap, equals(['plato favorito', 'ingredientes']));
    });
  });
}


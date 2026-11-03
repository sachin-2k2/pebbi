import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/api_client.dart';
import 'package:peddi/features/missions/data/remote_conversation_repository.dart';
import 'package:peddi/features/missions/domain/correction_style.dart';
import 'package:peddi/features/missions/domain/mission_mode.dart';
import 'package:peddi/features/missions/domain/mission_support.dart';
import 'package:peddi/features/missions/domain/session_config.dart';
import '../../../core/network/fake_http_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemoteConversationRepository Free Talk Tests', () {
    late FakeHttpClientAdapter fakeAdapter;
    late ApiClient apiClient;
    late RemoteConversationRepository repo;

    const startPayload = {
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

    const messagePayload = {
      'character_text': '¡La pizza es deliciosa! ¿Qué ingredientes te gustan más?',
      'translation': 'Pizza is delicious! What ingredients do you like most?',
      'live_correction': '💡 Tip: Say "Me gusta" instead of "Yo gusta"',
      'completed_goals': ['Keep the conversation going'],
      'is_finished': false,
      'options': [
        {
          'text': 'Me gusta con mucho queso.',
          'translation': 'I like it with lots of cheese.',
        },
      ],
    };

    const debriefPayload = {
      'topic': 'Food',
      'completed_goals': [
        'Keep the conversation going',
        'Ask one question back',
        'Use a phrase you just learned',
      ],
      'total_messages': 6,
      'debrief': {
        'praise': 'Great job! You maintained a smooth conversation about food.',
        'corrections': [
          {
            'user_said': 'Yo gusta pizza',
            'better_way': 'Me gusta la pizza',
            'explanation': 'In Spanish, we use "me gusta".',
          },
        ],
        'vocabulary_recap': ['plato favorito', 'ingredientes', 'deliciosa'],
      },
    };

    setUp(() {
      fakeAdapter = FakeHttpClientAdapter();
      apiClient = ApiClient(adapter: fakeAdapter);
      repo = RemoteConversationRepository(apiClient: apiClient);
    });

    test('startSession calls /api/missions/freetalk/start when isFreeTalk is true', () async {
      fakeAdapter.onJson(
        '/api/missions/freetalk/start',
        jsonEncode(startPayload),
      );

      const config = SessionConfig(
        missionId: 'freetalk_Food',
        mode: MissionMode.chat,
        support: MissionSupport.guided,
        correctionStyle: CorrectionStyle.gentle,
        captionsOn: true,
        targetLanguageCode: 'es',
        explanationLanguageCode: 'en',
        freeTalkTopic: 'Food',
      );

      final result = await repo.startSession(config);

      expect(result.sessionId, equals('6724a1b8c4d29e3a89012345'));
      expect(result.characterName, equals('Pebbi'));
      expect(result.goals.length, equals(3));
      expect(result.initialMessage.targetText, equals('¡Hola! Hoy me encantaría hablar de comida.'));
      expect(result.suggestions.length, equals(1));
    });

    test('sendTurn calls /api/missions/freetalk/message and parses live correction', () async {
      fakeAdapter.onJson(
        '/api/missions/freetalk/start',
        jsonEncode(startPayload),
      );
      fakeAdapter.onJson(
        '/api/missions/freetalk/message',
        jsonEncode(messagePayload),
      );

      const config = SessionConfig(
        missionId: 'freetalk_Food',
        mode: MissionMode.chat,
        support: MissionSupport.guided,
        correctionStyle: CorrectionStyle.live,
        captionsOn: true,
        targetLanguageCode: 'es',
        explanationLanguageCode: 'en',
        freeTalkTopic: 'Food',
      );

      final start = await repo.startSession(config);

      final turn = await repo.sendTurn(
        sessionId: start.sessionId,
        clientTurnId: 'turn_1',
        userText: 'Me encanta la pizza y la pasta.',
        config: config,
      );

      expect(turn.characterMessage.targetText, contains('¡La pizza es deliciosa!'));
      expect(turn.correction, equals('💡 Tip: Say "Me gusta" instead of "Yo gusta"'));
      expect(turn.completedGoalIds, contains('1'));
      expect(turn.suggestions.length, equals(1));
    });

    test('finishSession calls /api/missions/freetalk/debrief and parses corrections and praise', () async {
      fakeAdapter.onJson(
        '/api/missions/freetalk/start',
        jsonEncode(startPayload),
      );
      fakeAdapter.onJson(
        '/api/missions/freetalk/debrief',
        jsonEncode(debriefPayload),
      );

      const config = SessionConfig(
        missionId: 'freetalk_Food',
        mode: MissionMode.chat,
        support: MissionSupport.guided,
        correctionStyle: CorrectionStyle.gentle,
        captionsOn: true,
        targetLanguageCode: 'es',
        explanationLanguageCode: 'en',
        freeTalkTopic: 'Food',
      );

      final start = await repo.startSession(config);
      final debrief = await repo.finishSession(start.sessionId);

      expect(debrief.missionId, equals('freetalk'));
      expect(debrief.characterName, equals('Pebbi'));
      expect(debrief.turnsCount, equals(6));
      expect(debrief.praise, contains('Great job!'));
      expect(debrief.corrections.length, equals(1));
      expect(debrief.corrections.first.userSaid, equals('Yo gusta pizza'));
      expect(debrief.corrections.first.betterWay, equals('Me gusta la pizza'));
      expect(debrief.vocabularyRecap, equals(['plato favorito', 'ingredientes', 'deliciosa']));
    });
  });
}


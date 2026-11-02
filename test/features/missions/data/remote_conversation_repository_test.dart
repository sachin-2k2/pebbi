import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  group('RemoteConversationRepository Tests', () {
    late FakeHttpClientAdapter fakeAdapter;
    late ApiClient apiClient;
    late RemoteConversationRepository repo;

    const config = SessionConfig(
      missionId: 'order-a-coffee',
      mode: MissionMode.chat,
      support: MissionSupport.guided,
      correctionStyle: CorrectionStyle.gentle,
      captionsOn: true,
      targetLanguageCode: 'es',
      explanationLanguageCode: 'en',
    );

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      fakeAdapter = FakeHttpClientAdapter();
      apiClient = ApiClient(adapter: fakeAdapter);
      repo = RemoteConversationRepository(apiClient: apiClient);
    });

    test('startSession calls start and detail endpoints', () async {
      fakeAdapter.onJson(
        '/api/missions/order-a-coffee/start',
        jsonEncode({
          'mission_id': 'order-a-coffee',
          'status': 'in_progress',
          'initial_message': {
            'character_text': '¡Hola! Buenos días.',
            'translation': 'Hello! Good morning.',
          },
          'options': [
            {'text': '¡Hola!', 'translation': 'Hello!'},
            {'text': 'Buenos días.', 'translation': 'Good morning.'},
          ],
        }),
      );
      fakeAdapter.onJson(
        '/api/missions/order-a-coffee',
        jsonEncode({
          'mission_id': 'order-a-coffee',
          'title': 'Order a coffee',
          'character_name': 'Lucía',
          'character_role': 'barista',
          'icon': '☕',
          'goals': [
            {'id': 1, 'goal': 'Order a drink', 'completed': false},
          ],
        }),
      );

      final session = await repo.startSession(config);

      expect(session.sessionId, startsWith('session_'));
      expect(session.characterName, 'Lucía');
      expect(session.characterRole, 'barista');
      expect(session.emoji, '☕');
      expect(session.initialMessage.targetText, '¡Hola! Buenos días.');
      expect(session.initialMessage.translationText, 'Hello! Good morning.');
      expect(session.goals.length, 1);
      expect(session.suggestions.length, 2);
      expect(session.suggestions[0].text, '¡Hola!');
    });

    test('sendTurn calls message endpoint and ticks completed goals', () async {
      fakeAdapter.onJson(
        '/api/missions/order-a-coffee/start',
        jsonEncode({
          'mission_id': 'order-a-coffee',
          'status': 'in_progress',
          'initial_message': {
            'character_text': '¡Hola!',
            'translation': 'Hello!',
          },
        }),
      );
      fakeAdapter.onJson(
        '/api/missions/order-a-coffee',
        jsonEncode({
          'mission_id': 'order-a-coffee',
          'goals': [
            {'id': 1, 'goal': 'Order a drink', 'completed': false},
          ],
        }),
      );

      final session = await repo.startSession(config);

      fakeAdapter.onJson(
        '/api/missions/order-a-coffee/message',
        jsonEncode({
          'character_text': 'Un café, perfecto.',
          'translation': 'A coffee, perfect.',
          'completed_goals': ['Order a drink'],
          'is_finished': false,
          'options': [
            {'text': '¿Cuánto cuesta?', 'translation': 'How much is it?'},
          ],
        }),
      );

      final turn = await repo.sendTurn(
        sessionId: session.sessionId,
        clientTurnId: 'turn_1',
        userText: 'coffee please',
        config: config,
      );

      expect(turn.characterMessage.targetText, 'Un café, perfecto.');
      expect(turn.characterMessage.translationText, 'A coffee, perfect.');
      expect(turn.completedGoalIds, contains('1'));
      expect(turn.isFinished, isFalse);
      expect(turn.suggestions.length, 1);
      expect(turn.suggestions[0].text, '¿Cuánto cuesta?');
    });

    test('finishSession calls complete endpoint and returns DebriefRef', () async {
      fakeAdapter.onJson(
        '/api/missions/order-a-coffee/start',
        jsonEncode({'mission_id': 'order-a-coffee'}),
      );
      fakeAdapter.onJson(
        '/api/missions/order-a-coffee',
        jsonEncode({'mission_id': 'order-a-coffee', 'goals': []}),
      );

      final session = await repo.startSession(config);

      fakeAdapter.onJson(
        '/api/missions/order-a-coffee/complete',
        jsonEncode({
          'mission_id': 'order-a-coffee',
          'status': 'complete',
        }),
      );

      final debrief = await repo.finishSession(session.sessionId);

      expect(debrief.missionId, 'order-a-coffee');
      expect(debrief.sessionId, session.sessionId);
    });
  });
}


import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/api_client.dart';
import 'package:peddi/features/missions/data/mock_mission_repository.dart';
import 'package:peddi/features/missions/data/remote_mission_repository.dart';
import '../../../core/network/fake_http_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemoteMissionRepository Tests', () {
    late FakeHttpClientAdapter fakeAdapter;
    late ApiClient apiClient;
    late MockMissionRepository localFallback;
    late RemoteMissionRepository missionRepository;
    String? expiredUserId;

    const sampleTodayJson = {
      'mission_id': 'order-a-coffee',
      'title': 'Order a coffee',
      'character_name': 'Lucia',
      'character_role': 'barista',
      'duration_minutes': 5,
      'category': 'Everyday',
      'icon': '☕',
      'description': 'Practice ordering your favorite coffee drink.',
      'status': 'not_started',
    };

    const sampleMissionsJson = {
      'categories': ['All', 'Everyday', 'Travel', 'Health', 'Money', 'Social'],
      'missions': [
        {
          'mission_id': 'order-a-coffee',
          'title': 'Order a coffee',
          'character_name': 'Lucia',
          'character_role': 'barista',
          'duration_minutes': 5,
          'category': 'Everyday',
          'icon': '☕',
          'status': 'not_started',
        },
        {
          'mission_id': 'ask-for-directions',
          'title': 'Ask for directions',
          'character_name': 'Karim',
          'character_role': 'a passer-by',
          'duration_minutes': 5,
          'category': 'Travel',
          'icon': '🗺️',
          'status': 'not_started',
        },
      ],
    };

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      fakeAdapter = FakeHttpClientAdapter();
      apiClient = ApiClient(adapter: fakeAdapter);
      localFallback = MockMissionRepository();
      missionRepository = RemoteMissionRepository(
        apiClient: apiClient,
        fallbackRepository: localFallback,
        onSessionExpired: (uid) => expiredUserId = uid,
      );
      expiredUserId = null;
    });

    test('getTodayMission fetches from GET /api/missions/today', () async {
      fakeAdapter.onJson('/api/missions/today', jsonEncode(sampleTodayJson));

      final today = await missionRepository.getTodayMission(
        targetLanguageCode: 'es',
        userId: 'user_1',
      );

      expect(today, isNotNull);
      expect(today!.mission.id, 'order-a-coffee');
      expect(today.mission.title, 'Order a coffee');
      expect(today.mission.characterName, 'Lucia');
      expect(today.mission.characterRole, 'barista');
      expect(today.mission.emoji, '☕');
      expect(today.isCompleted, isFalse);
    });

    test('getMissions fetches list from GET /api/missions', () async {
      fakeAdapter.onJson('/api/missions', jsonEncode(sampleMissionsJson));

      final missions = await missionRepository.getMissions(
        targetLanguageCode: 'es',
        userId: 'user_1',
      );

      expect(missions.length, 2);
      expect(missions[0].id, 'order-a-coffee');
      expect(missions[1].id, 'ask-for-directions');
    });

    test('getCategories extracts categories from GET /api/missions', () async {
      fakeAdapter.onJson('/api/missions', jsonEncode(sampleMissionsJson));

      final categories = await missionRepository.getCategories(
        targetLanguageCode: 'es',
      );

      expect(categories.length, 6);
      expect(categories[0].id, 'all');
      expect(categories[1].id, 'everyday');
      expect(categories[2].id, 'travel');
    });

    test('startMission calls POST /api/missions/{id}/start', () async {
      fakeAdapter.onJson(
        '/api/missions/order-a-coffee/start',
        jsonEncode({'mission_id': 'order-a-coffee', 'status': 'in_progress'}),
      );

      await missionRepository.startMission(missionId: 'order-a-coffee');
      // Succeeds without exception
    });

    test('completeMission calls POST /api/missions/{id}/complete', () async {
      fakeAdapter.onJson(
        '/api/missions/order-a-coffee/complete',
        jsonEncode({'mission_id': 'order-a-coffee', 'status': 'complete'}),
      );

      await missionRepository.completeMission(missionId: 'order-a-coffee');
      // Succeeds without exception
    });

    test('returns null when backend returns today_mission: null or error', () async {
      fakeAdapter.onJson(
        '/api/missions/today',
        jsonEncode({'today_mission': null}),
      );

      final today = await missionRepository.getTodayMission(
        targetLanguageCode: 'es',
        userId: 'user_1',
      );

      expect(today, isNull);
    });

    test('returns empty list when backend returns empty missions array', () async {
      fakeAdapter.onJson(
        '/api/missions',
        jsonEncode({
          'categories': ['All', 'Everyday', 'Travel'],
          'missions': [],
        }),
      );

      final missions = await missionRepository.getMissions(
        targetLanguageCode: 'es',
        userId: 'user_1',
      );

      expect(missions, isEmpty);
    });

    test('loadBrief fetches mission detail from GET /api/missions/{id}', () async {
      fakeAdapter.onJson(
        '/api/missions/order-a-coffee',
        jsonEncode({
          'mission_id': 'order-a-coffee',
          'title': 'Order a coffee',
          'character_name': 'Lucía',
          'character_role': 'barista',
          'duration_minutes': 5,
          'category': 'Everyday',
          'icon': '☕',
          'description': 'Practice ordering coffee',
          'scene': 'A busy café, morning rush',
          'goals': [
            {'id': 1, 'goal': 'Order a drink', 'completed': false},
          ],
        }),
      );

      final brief = await missionRepository.loadBrief(
        missionId: 'order-a-coffee',
        userId: 'user_1',
        targetLanguageCode: 'es',
        explanationLanguageCode: 'en',
      );

      expect(brief, isNotNull);
      expect(brief!.missionId, 'order-a-coffee');
      expect(brief.sceneLine, 'A busy café, morning rush');
      expect(brief.goals.length, 1);
      expect(brief.goals.first.text, 'Order a drink');
    });

    test('triggers onSessionExpired on 401 Unauthorized', () async {
      await apiClient.tokenStorage.saveSession('user_expired', 'token_123');
      fakeAdapter.onJson(
        '/api/missions/today',
        '{"detail":"Not authenticated"}',
        statusCode: 401,
      );

      await missionRepository.getTodayMission(
        targetLanguageCode: 'es',
        userId: 'user_expired',
      );

      expect(expiredUserId, 'user_expired');
    });
  });
}

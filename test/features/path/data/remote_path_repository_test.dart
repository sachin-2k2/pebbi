import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/api_client.dart';
import 'package:peddi/features/path/data/mock_path_repository.dart';
import 'package:peddi/features/path/data/remote_path_repository.dart';
import 'package:peddi/features/path/domain/path_node.dart';
import '../../../core/network/fake_http_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemotePathRepository Integration Tests', () {
    late FakeHttpClientAdapter fakeAdapter;
    late ApiClient apiClient;
    late MockPathRepository localFallback;
    late RemotePathRepository pathRepository;

    const sampleTrackJson = {
      'track_id': 'daily',
      'lessons': [
        {
          'lesson_id': 'daily-starter-1',
          'lesson_number': 1,
          'level': 'starter',
          'level_order': 1,
          'title': 'Say Hello',
          'icon': '👋',
          'xp_reward': 10,
          'status': 'complete',
          'locked': false,
        },
        {
          'lesson_id': 'daily-starter-2',
          'lesson_number': 2,
          'level': 'starter',
          'level_order': 2,
          'title': 'At the Café',
          'icon': '☕',
          'xp_reward': 10,
          'status': 'not_started',
          'locked': false,
        },
      ],
    };

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      fakeAdapter = FakeHttpClientAdapter();
      apiClient = ApiClient(adapter: fakeAdapter);
      localFallback = MockPathRepository();
      pathRepository = RemotePathRepository(
        apiClient: apiClient,
        localFallback: localFallback,
      );
    });

    test('getTracks returns default language-neutral tracks when guest', () async {
      final tracks = await pathRepository.getTracks();
      expect(tracks.length, equals(2));
      expect(tracks[0].id, equals('daily'));
      expect(tracks[0].title, equals('Daily Conversations'));
      expect(tracks[1].id, equals('job'));
      expect(tracks[1].title, equals('Career & Workplace'));
    });

    test('getTracks dispatches GET /api/tracks with Bearer token when authenticated', () async {
      await apiClient.tokenStorage.saveSession(
        'user_123',
        'jwt_token_tracks_abc',
      );

      fakeAdapter.onJson(
        '/api/tracks',
        jsonEncode([
          {
            'track_id': 'daily',
            'title': 'Daily Conversations',
            'description': 'Everyday conversations',
            'icon': '🌍',
            'total_lessons': 18,
            'is_recommended': true,
          },
          {
            'track_id': 'job',
            'title': 'Career & Workplace',
            'description': 'Professional communication',
            'icon': '💼',
            'total_lessons': 18,
            'is_recommended': false,
          },
        ]),
      );

      final tracks = await pathRepository.getTracks();
      expect(tracks.length, equals(2));
      expect(tracks[0].title, equals('Daily Conversations'));
      expect(tracks[0].isRecommended, isTrue);
      expect(tracks[1].title, equals('Career & Workplace'));
      expect(tracks[1].isRecommended, isFalse);

      final req = fakeAdapter.recordedRequests.firstWhere((r) => r.path == '/api/tracks');
      expect(req.method, equals('GET'));
      expect(req.headers['Authorization'], equals('Bearer jwt_token_tracks_abc'));
    });

    test('getUnitsForTrack dispatches GET /api/lessons/track/{id} with Bearer token when authenticated', () async {
      await apiClient.tokenStorage.saveSession(
        'user_123',
        'jwt_token_lessons_abc',
      );

      fakeAdapter.onJson(
        '/api/lessons/track/daily',
        jsonEncode(sampleTrackJson),
      );

      final units = await pathRepository.getUnitsForTrack(
        'daily',
        userId: 'user_123',
      );

      expect(units.isNotEmpty, isTrue);
      expect(units[0].trackId, equals('daily'));
      expect(units[0].nodes.length, equals(3)); // 2 lessons + chest
      expect(units[0].nodes[0].id, equals('daily-starter-1'));
      expect(units[0].nodes[0].state, equals(NodeState.done));
      expect(units[0].nodes[1].id, equals('daily-starter-2'));
      expect(units[0].nodes[1].state, equals(NodeState.current));

      // Verify request
      expect(fakeAdapter.recordedRequests.length, equals(1));
      final recorded = fakeAdapter.recordedRequests.first;
      expect(recorded.method, equals('GET'));
      expect(recorded.path, equals('/api/lessons/track/daily'));
      expect(recorded.headers['Authorization'], equals('Bearer jwt_token_lessons_abc'));
    });

    test('getUnitsForTrack falls back to local fallback when guest user', () async {
      await apiClient.tokenStorage.saveSession('guest_test_id', '');

      final units = await pathRepository.getUnitsForTrack(
        'daily',
        userId: 'guest_test_id',
      );

      expect(units.isNotEmpty, isTrue);
      expect(fakeAdapter.recordedRequests, isEmpty);
    });
  });
}

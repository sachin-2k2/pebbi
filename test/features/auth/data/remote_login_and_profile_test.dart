import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/api_client.dart';
import 'package:peddi/features/auth/data/mock_secure_session_store.dart';
import 'package:peddi/features/auth/data/remote_auth_repository.dart';
import 'package:peddi/features/auth/data/remote_profile_repository.dart';
import 'package:peddi/features/auth/domain/auth_result.dart';
import '../../../core/network/fake_http_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Remote Auth & Profile Integration Tests', () {
    late FakeHttpClientAdapter fakeAdapter;
    late ApiClient apiClient;
    late MockSecureSessionStore secureStore;
    late RemoteAuthRepository authRepository;
    late RemoteProfileRepository profileRepository;

    const sampleProfileJson = {
      'id': '671cc85341f237bf81d2a191',
      'display_name': 'Farsana',
      'email': 'user@example.com',
      'native_language': 'ml',
      'learning_language': 'en',
      'current_level': 'starter',
      'level': 'starter',
      'suggested_level': 'starter',
      'placement_skipped': false,
      'placement_score': 6,
      'placement_total': 8,
      'age_band': '18-24',
      'learning_goals': ['travel', 'work'],
      'daily_goal': 'regular',
      'reminder_time': '19:00',
      'reminder_days': ['Monday', 'Wednesday', 'Friday'],
      'accent_color': 'violet',
      'first_sticker': 'first_hello',
      'onboarding_done': true,
    };

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      fakeAdapter = FakeHttpClientAdapter();
      apiClient = ApiClient(adapter: fakeAdapter);
      secureStore = MockSecureSessionStore();
      authRepository = RemoteAuthRepository(
        apiClient: apiClient,
        secureStore: secureStore,
      );
      profileRepository = RemoteProfileRepository(
        apiClient: apiClient,
      );
    });

    test('signInWithEmail sends POST /api/auth/login, stores tokens, and returns AuthSuccess', () async {
      fakeAdapter.onJson(
        '/api/auth/login',
        jsonEncode({
          'access_token': 'jwt_login_token_xyz',
          'token_type': 'bearer',
          'user': sampleProfileJson,
        }),
      );

      final result = await authRepository.signInWithEmail(
        email: 'user@example.com',
        password: 'Password123',
      );

      expect(result, isA<AuthSuccess>());
      final success = result as AuthSuccess;
      expect(success.session.userId, equals('671cc85341f237bf81d2a191'));
      expect(success.session.accessToken, equals('jwt_login_token_xyz'));
      expect(success.profile?.firstName, equals('Farsana'));
      expect(success.profile?.targetLanguageCode, equals('en'));
      expect(success.profile?.explanationLanguageCode, equals('ml'));

      // Verify tokens stored into both SecureStore and ApiClient TokenStorage
      expect(await secureStore.getAccessToken(), equals('jwt_login_token_xyz'));
      expect(await secureStore.getUserId(), equals('671cc85341f237bf81d2a191'));
      final active = await apiClient.tokenStorage.getActiveSession();
      expect(active?.token, equals('jwt_login_token_xyz'));
      expect(active?.userId, equals('671cc85341f237bf81d2a191'));

      // Verify request payload
      expect(fakeAdapter.recordedRequests.length, equals(1));
      final recorded = fakeAdapter.recordedRequests.first;
      expect(recorded.method, equals('POST'));
      expect(recorded.path, equals('/api/auth/login'));
      expect(recorded.body['email'], equals('user@example.com'));
      expect(recorded.body['password'], equals('Password123'));
    });

    test('RemoteProfileRepository fetches GET /api/me with Bearer token and returns UserProfile', () async {
      // Seed active token
      await apiClient.tokenStorage.saveSession(
        '671cc85341f237bf81d2a191',
        'jwt_bearer_token_abc',
      );

      fakeAdapter.onJson(
        '/api/me',
        jsonEncode({'user': sampleProfileJson}),
      );

      final profile = await profileRepository.getCurrentProfile();

      expect(profile, isNotNull);
      expect(profile!.userId, equals('671cc85341f237bf81d2a191'));
      expect(profile.firstName, equals('Farsana'));
      expect(profile.targetLanguageCode, equals('en'));
      expect(profile.explanationLanguageCode, equals('ml'));
      expect(profile.reasonIds, containsAll(['travel', 'work']));
      expect(profile.dailyGoalId, equals('regular'));
      expect(profile.remindersEnabled, isTrue);

      // Verify Bearer authorization header was attached
      expect(fakeAdapter.recordedRequests.length, equals(1));
      final recorded = fakeAdapter.recordedRequests.first;
      expect(recorded.method, equals('GET'));
      expect(recorded.path, equals('/api/me'));
      expect(recorded.headers['Authorization'], equals('Bearer jwt_bearer_token_abc'));
    });
  });
}

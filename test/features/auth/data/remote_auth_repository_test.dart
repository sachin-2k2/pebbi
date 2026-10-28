import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/api_client.dart';
import 'package:peddi/features/auth/data/mock_secure_session_store.dart';
import 'package:peddi/features/auth/data/remote_auth_repository.dart';
import 'package:peddi/features/auth/domain/auth_result.dart';
import '../../../core/network/fake_http_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemoteAuthRepository Integration Tests', () {
    late FakeHttpClientAdapter fakeAdapter;
    late ApiClient apiClient;
    late MockSecureSessionStore secureStore;
    late RemoteAuthRepository repository;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      fakeAdapter = FakeHttpClientAdapter();
      apiClient = ApiClient(adapter: fakeAdapter);
      secureStore = MockSecureSessionStore();
      repository = RemoteAuthRepository(
        apiClient: apiClient,
        secureStore: secureStore,
      );
    });

    test('registerWithEmail sends POST /api/auth/register and returns RegisterOtpSent', () async {
      fakeAdapter.onJson(
        '/api/auth/register',
        jsonEncode({
          'message': 'Verification code sent to test@example.com',
          'expires_in': '10 minutes',
        }),
      );

      final onboardingData = {
        'native_language': 'ml',
        'learning_language': 'en',
        'current_level': 'starter',
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
      };

      final result = await repository.registerWithEmail(
        email: 'test@example.com',
        password: 'Password123',
        displayName: 'Farsana',
        onboardingData: onboardingData,
      );

      expect(result, isA<RegisterOtpSent>());
      final otpSent = result as RegisterOtpSent;
      expect(otpSent.email, equals('test@example.com'));
      expect(otpSent.expiresIn, equals('10 minutes'));
      expect(otpSent.message, contains('Verification code sent'));

      expect(fakeAdapter.recordedRequests.length, equals(1));
      final recorded = fakeAdapter.recordedRequests.first;
      expect(recorded.method, equals('POST'));
      expect(recorded.path, equals('/api/auth/register'));
      expect(recorded.body['email'], equals('test@example.com'));
      expect(recorded.body['display_name'], equals('Farsana'));
      expect(recorded.body['native_language'], equals('ml'));
      expect(recorded.body['learning_language'], equals('en'));
      expect(recorded.body['current_level'], equals('starter'));
    });

    test('verifyOtp sends POST /api/auth/verify-otp, stores tokens, and returns AuthSuccess', () async {
      fakeAdapter.onJson(
        '/api/auth/verify-otp',
        jsonEncode({
          'access_token': 'jwt_access_token_123',
          'token_type': 'bearer',
          'user': {
            'id': '671cc85341f237bf81d2a191',
            'display_name': 'Farsana',
            'email': 'test@example.com',
            'native_language': 'ml',
            'learning_language': 'en',
            'current_level': 'starter',
            'suggested_level': 'starter',
            'age_band': '18-24',
            'learning_goals': ['travel', 'work'],
            'daily_goal': 'regular',
            'reminder_time': '19:00',
            'reminder_days': ['Monday', 'Wednesday', 'Friday'],
            'accent_color': 'violet',
            'first_sticker': 'first_hello',
            'onboarding_done': true,
          },
        }),
      );

      final result = await repository.verifyOtp(
        email: 'test@example.com',
        otp: '123456',
      );

      expect(result, isA<AuthSuccess>());
      final success = result as AuthSuccess;
      expect(success.session.userId, equals('671cc85341f237bf81d2a191'));
      expect(success.session.accessToken, equals('jwt_access_token_123'));
      expect(success.profile?.firstName, equals('Farsana'));
      expect(success.profile?.targetLanguageCode, equals('en'));
      expect(success.profile?.explanationLanguageCode, equals('ml'));

      // Verify tokens stored into secure store
      expect(await secureStore.getAccessToken(), equals('jwt_access_token_123'));
      expect(await secureStore.getUserId(), equals('671cc85341f237bf81d2a191'));

      expect(fakeAdapter.recordedRequests.length, equals(1));
      final recorded = fakeAdapter.recordedRequests.first;
      expect(recorded.method, equals('POST'));
      expect(recorded.path, equals('/api/auth/verify-otp'));
      expect(recorded.body['email'], equals('test@example.com'));
      expect(recorded.body['otp'], equals('123456'));
    });
  });
}

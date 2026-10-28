import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/auth_interceptor.dart';
import 'package:peddi/core/storage/token_storage.dart';

class InMemoryTokenStorage implements TokenStorage {
  String? activeUserId;
  String? token;

  @override
  bool get isSignedIn => activeUserId != null && token != null;

  @override
  ({String userId, String token})? get cachedSession {
    if (activeUserId != null && token != null) {
      return (userId: activeUserId!, token: token!);
    }
    return null;
  }

  @override
  void updateCache(({String userId, String token})? session) {
    activeUserId = session?.userId;
    token = session?.token;
  }

  @override
  Future<void> clearAll() async {
    activeUserId = null;
    token = null;
  }

  @override
  Future<void> saveSession(String userId, String token) async {
    activeUserId = userId;
    this.token = token;
  }

  @override
  Future<({String userId, String token})?> getActiveSession() async {
    if (activeUserId != null && token != null) {
      return (userId: activeUserId!, token: token!);
    }
    return null;
  }

  @override
  Future<void> clearSession() async {
    activeUserId = null;
    token = null;
  }

  @override
  Future<String?> getToken(String userId) async => token;

  @override
  Future<void> deleteToken(String userId) async {
    if (activeUserId == userId) {
      token = null;
    }
  }
}

void main() {
  group(
    'AuthInterceptor - Whole-segment and Base-relative Allow-list Matching',
    () {
      late InMemoryTokenStorage tokenStorage;
      late AuthInterceptor interceptor;

      setUp(() async {
        tokenStorage = InMemoryTokenStorage();
        await tokenStorage.saveSession('user_123', 'secret_jwt_token');
        interceptor = AuthInterceptor(tokenStorage: tokenStorage);
      });

      test(
        'exact match on public paths does NOT add Authorization header',
        () async {
          final options = RequestOptions(
            path: '/api/placement/questions',
            baseUrl: 'https://api.example.com',
          );

          final handler = RequestInterceptorHandler();
          await interceptor.onRequest(options, handler);

          expect(options.headers.containsKey('Authorization'), isFalse);
        },
      );

      test(
        'base-path prefixed public path does NOT add Authorization header',
        () async {
          final options = RequestOptions(
            path: '/placement/questions',
            baseUrl: 'https://api.example.com/api',
          );

          final handler = RequestInterceptorHandler();
          await interceptor.onRequest(options, handler);

          expect(options.headers.containsKey('Authorization'), isFalse);
        },
      );

      test(
        'segment boundaries: /api/auth/login-x is NOT public and gets Authorization header',
        () async {
          final options = RequestOptions(
            path: '/api/auth/login-x',
            baseUrl: 'https://api.example.com',
          );

          final handler = RequestInterceptorHandler();
          await interceptor.onRequest(options, handler);

          expect(
            options.headers['Authorization'],
            equals('Bearer secret_jwt_token'),
          );
        },
      );

      test('segment boundaries: /api/placement vs /api/placement/', () async {
        // /api/placement is NOT in the allow list (/api/placement/intro, /api/placement/questions, /api/placement/submit are)
        final options1 = RequestOptions(
          path: '/api/placement',
          baseUrl: 'https://api.example.com',
        );
        final handler1 = RequestInterceptorHandler();
        await interceptor.onRequest(options1, handler1);
        expect(
          options1.headers['Authorization'],
          equals('Bearer secret_jwt_token'),
        );

        final options2 = RequestOptions(
          path: '/api/placement/questions',
          baseUrl: 'https://api.example.com',
        );
        final handler2 = RequestInterceptorHandler();
        await interceptor.onRequest(options2, handler2);
        expect(options2.headers.containsKey('Authorization'), isFalse);
      });

      test('private endpoints receive Bearer token', () async {
        final options = RequestOptions(
          path: '/api/user/profile',
          baseUrl: 'https://api.example.com',
        );

        final handler = RequestInterceptorHandler();
        await interceptor.onRequest(options, handler);

        expect(
          options.headers['Authorization'],
          equals('Bearer secret_jwt_token'),
        );
      });
    },
  );
}

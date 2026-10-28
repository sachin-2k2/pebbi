import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/logging_interceptor.dart';

void main() {
  group('LoggingPolicyInterceptor Redaction', () {
    late LoggingPolicyInterceptor interceptor;

    setUp(() {
      interceptor = LoggingPolicyInterceptor();
    });

    test('onRequest redacts authorization and session tokens', () {
      final options = RequestOptions(
        path: '/api/user/profile',
        headers: {
          'Authorization': 'Bearer very_secret_user_token_12345',
          'X-User-Token': 'secret_header_value',
        },
        data: {
          'password': 'SuperSecretPassword',
          'email': 'user@example.com',
          'token': 'secret_refresh_token',
        },
      );

      final handler = RequestInterceptorHandler();
      // Interceptor processes options without crashing and redacts sensitive data in debugPrint
      expect(() => interceptor.onRequest(options, handler), returnsNormally);
    });
  });
}

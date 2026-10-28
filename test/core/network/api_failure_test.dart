import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/api_error_mapper.dart';
import 'package:peddi/core/network/api_failure.dart';

void main() {
  group('ApiFailure and ApiErrorMapper - Sensitive Data Redaction', () {
    test(
      '422 body with sensitive password and email does NOT leak into failure object',
      () {
        final fixtureFile = File('test/fixtures/api/error_validation_422.json');
        final jsonMap =
            jsonDecode(fixtureFile.readAsStringSync()) as Map<String, dynamic>;

        const sensitivePassword = 'P@ssword999';
        const sensitiveEmail = 'victim@example.com';

        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/auth/register'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/auth/register'),
            statusCode: 422,
            data: jsonMap,
          ),
          type: DioExceptionType.badResponse,
        );

        final failure = ApiErrorMapper.mapDioException(dioException);

        expect(failure, isA<ValidationFailure>());
        final validation = failure as ValidationFailure;

        // Assert only clean field names are stored
        expect(validation.invalidFields, contains('password'));
        expect(validation.invalidFields, contains('email'));

        // Assert sensitive strings never appear in failure string representation
        final failureString = failure.toString();
        expect(failureString.contains(sensitivePassword), isFalse);
        expect(failureString.contains(sensitiveEmail), isFalse);

        // Assert user friendly message does NOT contain raw error strings
        expect(validation.userMessage.contains(sensitivePassword), isFalse);
        expect(validation.userMessage.contains(sensitiveEmail), isFalse);
        expect(
          validation.userMessage,
          equals('Please check the provided information and try again.'),
        );
      },
    );

    test('500 server internal error never exposes server detail', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/test'),
          statusCode: 500,
          data: {
            'detail':
                'Database connection pool exhausted: postgres://root:secret@db:5432',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final failure = ApiErrorMapper.mapDioException(dioException);
      expect(failure, isA<ServerFailure>());
      final str = failure.toString();
      expect(str.contains('postgres'), isFalse);
      expect(str.contains('secret'), isFalse);
    });
  });
}

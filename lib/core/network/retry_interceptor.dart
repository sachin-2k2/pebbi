import 'dart:async';
import 'package:dio/dio.dart';

/// Interceptor that automatically retries safe, idempotent GET requests.
///
/// Follows AGENTS.md §2 & §5:
/// - Security Rule: NEVER auto-retries POST/PATCH/DELETE mutations (register,
///   verify-otp, login, answer submit).
/// - Automatically retries safe GET requests on network socket drops or 502/503/504.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 2,
    this.initialDelay = const Duration(milliseconds: 250),
  }) : _dio = dio;

  final Dio _dio;
  final int maxRetries;
  final Duration initialDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;

    // Strictly retry ONLY idempotent GET requests
    if (req.method.toUpperCase() != 'GET') {
      return handler.next(err);
    }

    final currentAttempt = (req.extra['retry_count'] as int?) ?? 0;
    if (currentAttempt >= maxRetries || !_isRetryable(err)) {
      return handler.next(err);
    }

    req.extra['retry_count'] = currentAttempt + 1;
    final delay = initialDelay * (1 << currentAttempt);
    await Future<void>.delayed(delay);

    try {
      final response = await _dio.fetch(req);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    } catch (_) {
      return handler.next(err);
    }
  }

  bool _isRetryable(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout) {
      return true;
    }
    final status = err.response?.statusCode;
    return status == 502 || status == 503 || status == 504;
  }
}

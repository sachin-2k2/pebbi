import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Privacy-safe network logging interceptor.
///
/// Follows AGENTS.md §2, §6 & project security guidelines:
/// - Active ONLY in debug builds ([kDebugMode]).
/// - Strictly redacts Authorization headers (`Bearer [REDACTED]`).
/// - NEVER logs request or response bodies, user emails, passwords, OTPs,
///   tokens, exercise phrases, answers, or emojis.
class LoggingPolicyInterceptor extends Interceptor {
  LoggingPolicyInterceptor({
    this.logPrinter = _defaultPrinter,
    this.enabled = kDebugMode,
  });

  final void Function(String line) logPrinter;
  final bool enabled;

  static void _defaultPrinter(String line) {
    if (kDebugMode) {
      debugPrint(line);
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled) return handler.next(options);

    final method = options.method.toUpperCase();
    final uri = options.uri.toString();
    final authHeader = options.headers['Authorization'];

    final headerInfo = authHeader != null ? ' [Auth: Bearer REDACTED]' : '';
    logPrinter('[HTTP Request] $method $uri$headerInfo');

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enabled) return handler.next(response);

    final status = response.statusCode;
    final uri = response.requestOptions.uri.toString();
    logPrinter('[HTTP Response] $status $uri');

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) return handler.next(err);

    final status = err.response?.statusCode;
    final uri = err.requestOptions.uri.toString();
    final type = err.type.name;
    logPrinter('[HTTP Error] $type (status: $status) $uri');

    return handler.next(err);
  }

  /// Sanitized debug log for skipped/invalid questions without leaking content.
  static void logInvalidQuestion(String questionId, String reason) {
    if (kDebugMode) {
      debugPrint(
        '[Placement] Skipping invalid question id=$questionId ($reason)',
      );
    }
  }
}

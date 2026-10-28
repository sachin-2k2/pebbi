import 'package:dio/dio.dart';
import 'api_failure.dart';

/// Maps HTTP exceptions and status codes into privacy-safe [ApiFailure]s.
///
/// Follows AGENTS.md §2 & §6:
/// - Security Rule: Never leaks server error messages, internal stack traces,
///   or echoed request values (passwords, tokens, emails).
/// - Maps by status code and extracts sanitized field names only.
class ApiErrorMapper {
  const ApiErrorMapper();

  static ApiFailure map(Object error) {
    if (error is DioException) {
      return mapDioException(error);
    }
    return const UnknownFailure();
  }

  static ApiFailure mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final data = e.response?.data;
        return _mapStatusCode(status, data);

      case DioExceptionType.cancel:
        return const UnknownFailure();

      case DioExceptionType.badCertificate:
        return const NetworkFailure();

      case DioExceptionType.unknown:
      default:
        return const NetworkFailure();
    }
  }

  static ApiFailure _mapStatusCode(int? status, dynamic data) {
    if (status == null) return const UnknownFailure();

    switch (status) {
      case 401:
      case 403:
        return const UnauthorizedFailure();

      case 404:
        return const NotFoundFailure();

      case 409:
        return const ConflictFailure();

      case 429:
        return const RateLimitedFailure();

      case 400:
      case 422:
        return _parseValidationFailure(data);

      default:
        if (status >= 500 && status < 600) {
          return ServerFailure(statusCode: status);
        }
        return const UnknownFailure();
    }
  }

  /// Extracts sanitized field names and high-level categorization from error data
  /// without preserving any raw strings or echoed user input.
  static ValidationFailure _parseValidationFailure(dynamic data) {
    final fieldNames = <String>[];
    var kind = 'invalid_request';

    if (data is Map<String, dynamic>) {
      final detail = data['detail'];

      if (detail is List) {
        // FastAPI / Pydantic validation structure:
        // [{"loc": ["body", "field_name"], "msg": "...", "type": "value_error.missing"}]
        for (final item in detail) {
          if (item is Map) {
            final loc = item['loc'];
            if (loc is List && loc.isNotEmpty) {
              final lastLoc = loc.last.toString();
              if (lastLoc != 'body' && !fieldNames.contains(lastLoc)) {
                fieldNames.add(lastLoc);
              }
            }
            final type = item['type']?.toString() ?? '';
            if (type.contains('missing')) {
              kind = 'missing_field';
            } else if (type.contains('email') || type.contains('format')) {
              kind = 'invalid_format';
            }
          }
        }
      } else if (detail is String) {
        // Simple string detail e.g. {"detail": "Invalid email or password"}
        // Do NOT store detail string! Classify based on high-level heuristics:
        final lower = detail.toLowerCase();
        if (lower.contains('email')) {
          fieldNames.add('email');
        }
        if (lower.contains('password')) {
          fieldNames.add('password');
        }
        if (lower.contains('otp')) {
          fieldNames.add('otp');
        }
        kind = lower.contains('missing') ? 'missing_field' : 'invalid_value';
      }
    } else if (data is List) {
      for (final item in data) {
        if (item is Map) {
          final loc = item['loc'];
          if (loc is List && loc.isNotEmpty) {
            final lastLoc = loc.last.toString();
            if (lastLoc != 'body' && !fieldNames.contains(lastLoc)) {
              fieldNames.add(lastLoc);
            }
          }
        }
      }
    }

    return ValidationFailure(
      fieldNames: List.unmodifiable(fieldNames),
      kind: kind,
    );
  }
}

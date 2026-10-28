import 'package:dio/dio.dart';
import '../domain/auth_result.dart';

/// Pure mapping utility translating auth endpoint [DioException]s into domain [AuthFailure]s.
///
/// Follows API-V2.md §6, §7, §8 & AGENTS.md §2.
abstract final class AuthApiErrorMapper {
  static AuthFailure map(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const AuthFailure(AuthFailureReason.network);
    }

    final data = e.response?.data;
    final detail = data is Map ? (data['detail'] ?? data['message'])?.toString() : null;

    if (e.response?.statusCode == 401) {
      return AuthFailure(AuthFailureReason.invalidCredentials, detail);
    }

    if (e.response?.statusCode == 400 && detail != null) {
      final lower = detail.toLowerCase();
      if (lower.contains('same') || lower.contains('spoken language')) {
        return AuthFailure(AuthFailureReason.sameLanguageError, detail);
      }
      if (lower.contains('already registered') || lower.contains('duplicate')) {
        return AuthFailure(AuthFailureReason.emailAlreadyInUse, detail);
      }
      if (lower.contains('password must have') || lower.contains('password')) {
        return AuthFailure(AuthFailureReason.weakPassword, detail);
      }
      if (lower.contains('invalid otp')) {
        return AuthFailure(AuthFailureReason.invalidOtp, detail);
      }
      if (lower.contains('expired')) {
        return AuthFailure(AuthFailureReason.otpExpired, detail);
      }
      return AuthFailure(AuthFailureReason.unknown, detail);
    }

    return AuthFailure(AuthFailureReason.unknown, detail);
  }
}

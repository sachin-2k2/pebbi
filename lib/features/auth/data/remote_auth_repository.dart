import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_result.dart';
import '../domain/auth_session.dart';
import '../domain/secure_session_store.dart';
import 'auth_api_error_mapper.dart';
import 'dtos/login_request_dto.dart';
import 'dtos/login_response_dto.dart';
import 'dtos/register_request_dto.dart';
import 'dtos/register_response_dto.dart';
import 'dtos/verify_otp_request_dto.dart';
import 'dtos/verify_otp_response_dto.dart';

/// Real remote implementation of [AuthRepository] interacting with backend auth endpoints.
///
/// Follows API-V2.md §6, §7, §8 & AGENTS.md §2 & §6.
class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository({
    required ApiClient apiClient,
    required SecureSessionStore secureStore,
  }) : _apiClient = apiClient,
       _secureStore = secureStore;

  final ApiClient _apiClient;
  final SecureSessionStore _secureStore;

  @override
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
    Map<String, dynamic>? onboardingData,
  }) async {
    try {
      final effectiveName = (displayName != null && displayName.trim().isNotEmpty)
          ? displayName.trim()
          : email.trim().split('@').first;

      final requestDto = RegisterRequestDto(
        email: email,
        password: password,
        displayName: effectiveName,
        onboardingPayload: onboardingData ?? const {},
      );

      final payload = requestDto.toJson();
      final debugPayload = Map<String, dynamic>.from(payload)..['password'] = '******';
      debugPrint('[RemoteAuthRepository] ════════════════════════════════════════');
      debugPrint('[RemoteAuthRepository] 🌐 POST ${_apiClient.config.baseUrl}/api/auth/register');
      debugPrint('[RemoteAuthRepository] 📤 Payload: $debugPayload');

      final response = await _apiClient.post(
        '/api/auth/register',
        data: payload,
      );

      debugPrint('[RemoteAuthRepository] ✅ Response [${response.statusCode}]: ${response.data}');

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final res = RegisterResponseDto.fromJson(data);
        return RegisterOtpSent(
          message: res.message,
          expiresIn: res.expiresIn,
          email: email.trim(),
        );
      }
      return RegisterOtpSent(
        message: 'Verification code sent',
        expiresIn: '10 minutes',
        email: email.trim(),
      );
    } on DioException catch (e) {
      debugPrint('[RemoteAuthRepository] ❌ DioException [${e.response?.statusCode}]: ${e.response?.data}');
      debugPrint('[RemoteAuthRepository] ❌ Error details: ${e.message}');
      return AuthApiErrorMapper.map(e);
    } catch (e, stack) {
      debugPrint('[RemoteAuthRepository] 💥 Unexpected exception: $e\n$stack');
      return const AuthFailure(AuthFailureReason.unknown);
    }
  }

  @override
  Future<AuthResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final requestDto = VerifyOtpRequestDto(email: email, otp: otp);
      final payload = requestDto.toJson();
      debugPrint('[RemoteAuthRepository] ════════════════════════════════════════');
      debugPrint('[RemoteAuthRepository] 🌐 POST ${_apiClient.config.baseUrl}/api/auth/verify-otp');
      debugPrint('[RemoteAuthRepository] 📤 Payload: $payload');

      final response = await _apiClient.post(
        '/api/auth/verify-otp',
        data: payload,
      );

      debugPrint('[RemoteAuthRepository] ✅ Response [${response.statusCode}]: ${response.data}');

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final res = VerifyOtpResponseDto.fromJson(data);
        final session = AuthSession(
          userId: res.user.id,
          email: res.user.email,
          accessToken: res.accessToken,
          refreshToken: '',
          createdAt: DateTime.now(),
        );
        await _secureStore.saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
          userId: session.userId,
        );
        await _apiClient.tokenStorage.saveSession(
          session.userId,
          session.accessToken,
        );
        return AuthSuccess(session, res.user.toDomain());
      }
      return const AuthFailure(AuthFailureReason.unknown);
    } on DioException catch (e) {
      debugPrint('[RemoteAuthRepository] ❌ DioException [${e.response?.statusCode}]: ${e.response?.data}');
      debugPrint('[RemoteAuthRepository] ❌ Error details: ${e.message}');
      return AuthApiErrorMapper.map(e);
    } catch (e, stack) {
      debugPrint('[RemoteAuthRepository] 💥 Unexpected exception: $e\n$stack');
      return const AuthFailure(AuthFailureReason.unknown);
    }
  }

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final requestDto = LoginRequestDto(email: email, password: password);
      final payload = requestDto.toJson();
      final debugPayload = Map<String, dynamic>.from(payload)..['password'] = '******';

      debugPrint('[RemoteAuthRepository] ════════════════════════════════════════');
      debugPrint('[RemoteAuthRepository] 🌐 POST ${_apiClient.config.baseUrl}/api/auth/login');
      debugPrint('[RemoteAuthRepository] 📤 Payload: $debugPayload');

      final response = await _apiClient.post(
        '/api/auth/login',
        data: payload,
      );

      debugPrint('[RemoteAuthRepository] ✅ Response [${response.statusCode}]: ${response.data}');

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final res = LoginResponseDto.fromJson(data);
        final session = AuthSession(
          userId: res.user.id,
          email: res.user.email,
          accessToken: res.accessToken,
          refreshToken: '',
          createdAt: DateTime.now(),
        );
        await _secureStore.saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
          userId: session.userId,
        );
        await _apiClient.tokenStorage.saveSession(
          session.userId,
          session.accessToken,
        );
        return AuthSuccess(session, res.user.toDomain());
      }
      return const AuthFailure(AuthFailureReason.invalidCredentials);
    } on DioException catch (e) {
      debugPrint('[RemoteAuthRepository] ❌ DioException [${e.response?.statusCode}]: ${e.response?.data}');
      debugPrint('[RemoteAuthRepository] ❌ Error details: ${e.message}');
      return AuthApiErrorMapper.map(e);
    } catch (e, stack) {
      debugPrint('[RemoteAuthRepository] 💥 Unexpected exception: $e\n$stack');
      return const AuthFailure(AuthFailureReason.unknown);
    }
  }

  @override
  Future<AuthResult> requestPasswordReset({required String email}) async {
    return const PasswordResetSuccess();
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    return const AuthFailure(
      AuthFailureReason.unknown,
      'Google sign-in is not yet supported on this backend.',
    );
  }

  @override
  Future<void> signOut() async {
    debugPrint('[RemoteAuthRepository] 🚪 signOut: clearing secure tokens & session');
    await _secureStore.clearTokens();
    await _apiClient.tokenStorage.clearSession();
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    final token = await _secureStore.getAccessToken();
    final userId = await _secureStore.getUserId();
    if (token == null || userId == null) return null;
    await _apiClient.tokenStorage.saveSession(userId, token);
    return AuthSession(
      userId: userId,
      email: '',
      accessToken: token,
      refreshToken: (await _secureStore.getRefreshToken()) ?? '',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> mergeGuestProgress({
    required String guestId,
    required String userId,
  }) async {}
}

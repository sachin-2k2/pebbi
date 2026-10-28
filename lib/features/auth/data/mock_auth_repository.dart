import 'package:flutter/foundation.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_result.dart';
import '../domain/auth_session.dart';
import '../domain/secure_session_store.dart';

/// Mock implementation of [AuthRepository] with realistic test behaviors.
///
/// Follows AGENTS.md §1 & §6: Implements mock authentication behind repository interface.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    SecureSessionStore? secureStore,
    AuthSession? initialSession,
    this.simulatedDelay = Duration.zero,
    this.forceFailureReason,
    this.forceGoogleCancel = false,
  }) : _secureStore = secureStore,
       _currentSession = initialSession;

  final SecureSessionStore? _secureStore;
  AuthSession? _currentSession;

  /// Optional simulated network delay.
  final Duration simulatedDelay;

  /// If non-null, operations fail with this specific failure reason.
  AuthFailureReason? forceFailureReason;

  /// If true, Google sign-in returns [AuthFailureReason.cancelled].
  bool forceGoogleCancel;

  /// Number of sign-in calls received (for double-tap verification).
  int signInAttempts = 0;

  /// Number of register calls received (for double-tap verification).
  int registerAttempts = 0;

  /// Number of password reset calls received (for double-tap verification).
  int passwordResetAttempts = 0;

  /// If true, guest progress migration fails.
  bool forceMigrationFailure = false;

  /// Recorded guest progress merges (guestId -> userId).
  final Map<String, String> mergedGuestProgressCalls = {};

  @override
  Future<AuthResult> requestPasswordReset({required String email}) async {
    passwordResetAttempts++;
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    if (forceFailureReason != null) {
      return AuthFailure(forceFailureReason!);
    }

    // Security Rule: Always return success for any email address
    // to strictly protect against account enumeration.
    return const PasswordResetSuccess();
  }

  /// If true, registerWithEmail returns RegisterOtpSent requiring verifyOtp call.
  bool simulateOtpFlow = false;

  /// Verification attempts received.
  int verifyOtpAttempts = 0;

  @override
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
    Map<String, dynamic>? onboardingData,
  }) async {
    registerAttempts++;
    debugPrint('[MockAuthRepository] ℹ️ registerWithEmail called (email: $email, simulateOtpFlow: $simulateOtpFlow)');
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    if (forceFailureReason != null) {
      debugPrint('[MockAuthRepository] ℹ️ forceFailureReason: $forceFailureReason');
      return AuthFailure(forceFailureReason!);
    }

    // Explicit test trigger for already registered email
    if (email.trim().toLowerCase() == 'alreadyregistered@example.com') {
      debugPrint('[MockAuthRepository] ℹ️ Email alreadyregistered trigger hit');
      return const AuthFailure(AuthFailureReason.emailAlreadyInUse);
    }

    if (simulateOtpFlow) {
      debugPrint('[MockAuthRepository] ℹ️ simulateOtpFlow=true -> Returning RegisterOtpSent');
      return RegisterOtpSent(
        message: 'Verification code sent to ${email.trim()}',
        expiresIn: '10 minutes',
        email: email.trim(),
      );
    }

    final userId = 'user_${email.trim().toLowerCase().hashCode.abs()}';
    debugPrint('[MockAuthRepository] ℹ️ simulateOtpFlow=false -> Mocking immediate AuthSuccess for $userId (skips OTP, directly enters app)');
    final session = AuthSession(
      userId: userId,
      email: email.trim(),
      accessToken: 'mock_jwt_access_token_$userId',
      refreshToken: 'mock_jwt_refresh_token_$userId',
      createdAt: DateTime.now(),
    );

    _currentSession = session;
    await _secureStore?.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userId: session.userId,
    );

    return AuthSuccess(session);
  }

  @override
  Future<AuthResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    verifyOtpAttempts++;
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    if (forceFailureReason != null) {
      return AuthFailure(forceFailureReason!);
    }

    if (otp == '000000') {
      return const AuthFailure(AuthFailureReason.otpExpired, 'OTP expired. Please request a new one.');
    }

    if (otp != '123456' && otp.length != 6) {
      return const AuthFailure(AuthFailureReason.invalidOtp, 'Invalid OTP. Please check and try again.');
    }

    final userId = 'user_${email.trim().toLowerCase().hashCode.abs()}';
    final session = AuthSession(
      userId: userId,
      email: email.trim(),
      accessToken: 'mock_jwt_access_token_$userId',
      refreshToken: 'mock_jwt_refresh_token_$userId',
      createdAt: DateTime.now(),
    );

    _currentSession = session;
    await _secureStore?.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userId: session.userId,
    );

    return AuthSuccess(session);
  }

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    signInAttempts++;
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    if (forceFailureReason != null) {
      return AuthFailure(forceFailureReason!);
    }

    // Explicit test triggers for invalid credentials
    if (email == 'wrong@example.com' || password == 'wrongpassword') {
      return const AuthFailure(AuthFailureReason.invalidCredentials);
    }

    final userId = 'user_${email.trim().toLowerCase().hashCode.abs()}';
    final session = AuthSession(
      userId: userId,
      email: email.trim(),
      accessToken: 'mock_jwt_access_token_$userId',
      refreshToken: 'mock_jwt_refresh_token_$userId',
      createdAt: DateTime.now(),
    );

    _currentSession = session;
    await _secureStore?.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userId: session.userId,
    );

    return AuthSuccess(session);
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    signInAttempts++;
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    if (forceGoogleCancel) {
      return const AuthFailure(AuthFailureReason.cancelled);
    }

    if (forceFailureReason != null) {
      return AuthFailure(forceFailureReason!);
    }

    final session = AuthSession(
      userId: 'user_google_999',
      email: 'alex.google@example.com',
      accessToken: 'mock_google_oauth_token_999',
      refreshToken: 'mock_google_refresh_token_999',
      createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
    );

    _currentSession = session;
    await _secureStore?.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userId: session.userId,
    );

    return AuthSuccess(session);
  }

  @override
  Future<void> signOut() async {
    _currentSession = null;
    await _secureStore?.clearTokens();
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    return _currentSession;
  }

  @override
  Future<void> mergeGuestProgress({
    required String guestId,
    required String userId,
  }) async {
    if (forceMigrationFailure) {
      throw Exception('Simulated guest migration failure');
    }
    mergedGuestProgressCalls[guestId] = userId;
  }
}

import 'auth_session.dart';
import 'user_profile.dart';

/// Reasons why an authentication attempt may fail.
enum AuthFailureReason {
  /// Incorrect email or password (always combined into a single message for security).
  invalidCredentials,

  /// No internet connection or network timeout.
  network,

  /// Rate limit exceeded on the server.
  tooManyAttempts,

  /// Third-party OAuth (e.g. Google) cancelled by the user.
  cancelled,

  /// Account has been disabled or locked by administration.
  accountDisabled,

  /// Email address is already registered in the system.
  emailAlreadyInUse,

  /// Password rejected by backend policy.
  weakPassword,

  /// Spoken language and learning language are identical.
  sameLanguageError,

  /// Invalid 6-digit OTP code provided.
  invalidOtp,

  /// 6-digit OTP code has expired.
  otpExpired,

  /// Unexpected server or client error.
  unknown,
}

/// Sealed outcome of an authentication request.
///
/// Follows AGENTS.md §2.2: Pure Dart rules and types with zero Flutter imports.
sealed class AuthResult {
  const AuthResult();
}

/// Successful authentication result containing the active session and optional profile.
class AuthSuccess extends AuthResult {
  const AuthSuccess(this.session, [this.profile]);
  final AuthSession session;
  final UserProfile? profile;
}

/// Successful step 1 registration: 6-digit verification code sent to email.
class RegisterOtpSent extends AuthResult {
  const RegisterOtpSent({
    required this.message,
    required this.expiresIn,
    required this.email,
  });

  final String message;
  final String expiresIn;
  final String email;
}

/// Successful password reset request result.
class PasswordResetSuccess extends AuthResult {
  const PasswordResetSuccess();
}

/// Failed authentication result with a categorized failure reason and optional message.
class AuthFailure extends AuthResult {
  const AuthFailure(this.reason, [this.message]);
  final AuthFailureReason reason;
  final String? message;
}

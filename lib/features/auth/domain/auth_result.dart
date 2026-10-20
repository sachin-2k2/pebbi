import 'auth_session.dart';

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

  /// Unexpected server or client error.
  unknown,
}

/// Sealed outcome of an authentication request.
///
/// Follows AGENTS.md §2.2: Pure Dart rules and types with zero Flutter imports.
sealed class AuthResult {
  const AuthResult();
}

/// Successful authentication result containing the active session.
class AuthSuccess extends AuthResult {
  const AuthSuccess(this.session);
  final AuthSession session;
}

/// Successful password reset request result.
class PasswordResetSuccess extends AuthResult {
  const PasswordResetSuccess();
}

/// Failed authentication result with a categorized failure reason.
class AuthFailure extends AuthResult {
  const AuthFailure(this.reason);
  final AuthFailureReason reason;
}

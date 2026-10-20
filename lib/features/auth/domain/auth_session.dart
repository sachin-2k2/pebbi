/// Domain model representing an authenticated user session.
///
/// Follows AGENTS.md §2.2: Pure Dart model with zero Flutter imports.
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.createdAt,
  });

  /// The unique authenticated user identifier.
  final String userId;

  /// User email address.
  final String email;

  /// JWT or OAuth access token.
  final String accessToken;

  /// Refresh token for issuing new access tokens.
  final String refreshToken;

  /// Session creation timestamp.
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSession &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          email == other.email &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken;

  @override
  int get hashCode => Object.hash(userId, email, accessToken, refreshToken);
}

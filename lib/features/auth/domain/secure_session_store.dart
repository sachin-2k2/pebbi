/// Interface for securely persisting authentication tokens in Keychain / Keystore.
///
/// Follows AGENTS.md §6: Tokens only in secure storage (flutter_secure_storage),
/// never in shared_preferences, plain databases, or application logs.
abstract interface class SecureSessionStore {
  /// Securely stores the active session tokens.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  });

  /// Retrieves the stored access token, or null if none exists.
  Future<String?> getAccessToken();

  /// Retrieves the stored refresh token, or null if none exists.
  Future<String?> getRefreshToken();

  /// Retrieves the stored authenticated user identifier, or null if none exists.
  Future<String?> getUserId();

  /// Deletes all authentication tokens upon logout or session termination.
  Future<void> clearTokens();
}

import '../domain/secure_session_store.dart';

/// In-memory mock of [SecureSessionStore] for development and testing.
///
/// Follows AGENTS.md §6: Verifies token persistence lifecycle without requiring native Keychain/Keystore.
class MockSecureSessionStore implements SecureSessionStore {
  MockSecureSessionStore({
    String? initialAccessToken,
    String? initialRefreshToken,
    String? initialUserId,
  }) : _accessToken = initialAccessToken,
       _refreshToken = initialRefreshToken,
       _userId = initialUserId;

  String? _accessToken;
  String? _refreshToken;
  String? _userId;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
  }

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<String?> getUserId() async => _userId;

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
  }
}

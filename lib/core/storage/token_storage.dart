import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure token storage backed by [FlutterSecureStorage].
///
/// Follows AGENTS.md §6 (User Isolation & Security) & Rules 1, 7, 9:
/// - Tokens stored strictly in Keychain/Keystore.
/// - Stores active session pointer [active_user_id] alongside isolated token keys.
/// - Edge cases: missing token with user id, or token without user id, or read errors
///   are treated as signed out safely without crashing.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
    : _storage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  ({String userId, String token})? _cachedSession;

  static const String _activeUserIdKey = 'active_user_id';
  static String _tokenKey(String userId) => 'token_$userId';

  /// Whether a valid active session is currently cached in-memory.
  bool get isSignedIn => _cachedSession != null;

  /// Retrieves the in-memory cached session tuple, or null.
  ({String userId, String token})? get cachedSession => _cachedSession;

  /// Explicitly updates or clears the in-memory cached session.
  void updateCache(({String userId, String token})? session) {
    _cachedSession = session;
  }

  /// Saves the authenticated [token] for [userId] and sets [userId] as the active user.
  Future<void> saveSession(String userId, String token) async {
    try {
      await _storage.write(key: _tokenKey(userId), value: token);
      await _storage.write(key: _activeUserIdKey, value: userId);
      _cachedSession = (userId: userId, token: token);
    } catch (_) {}
  }

  /// Retrieves the currently active user session credentials, or `null` if none exists.
  ///
  /// Enforces Rules 1 & 7:
  /// - Both token AND user ID must exist and be non-empty.
  /// - If one exists but the other is missing: treats as signed out and clears both.
  /// - If reading throws an exception (unreadable): treats as signed out without crashing.
  Future<({String userId, String token})?> getActiveSession() async {
    try {
      final all = await _storage.readAll();
      final activeUserId = all[_activeUserIdKey]?.trim();
      final hasActiveUserId = activeUserId != null && activeUserId.isNotEmpty;

      final userToken = hasActiveUserId ? all[_tokenKey(activeUserId)]?.trim() : null;
      final hasUserToken = userToken != null && userToken.isNotEmpty;

      final anyTokenKey = all.keys.firstWhere(
        (k) => k.startsWith('token_') && (all[k]?.trim().isNotEmpty ?? false),
        orElse: () => '',
      );
      final hasAnyToken = anyTokenKey.isNotEmpty;

      // Edge case (Rule 7): Token exists but user id missing, or the reverse
      if ((hasActiveUserId && !hasUserToken) || (!hasActiveUserId && hasAnyToken)) {
        await clearAll();
        _cachedSession = null;
        return null;
      }

      if (hasActiveUserId && hasUserToken) {
        final session = (userId: activeUserId, token: userToken);
        _cachedSession = session;
        return session;
      }

      _cachedSession = null;
      return null;
    } catch (_) {
      // Secure storage cannot be read (error): treat as signed out, never crash
      _cachedSession = null;
      return null;
    }
  }

  /// Retrieves the stored token for a specific [userId].
  Future<String?> getToken(String userId) async {
    try {
      return await _storage.read(key: _tokenKey(userId));
    } catch (_) {
      return null;
    }
  }

  /// Clears the active session and the associated token for the active user.
  Future<void> clearSession() async {
    try {
      _cachedSession = null;
      final activeUserId = await _storage.read(key: _activeUserIdKey);
      if (activeUserId != null && activeUserId.isNotEmpty) {
        await _storage.delete(key: _tokenKey(activeUserId));
      }
      await _storage.delete(key: _activeUserIdKey);
    } catch (_) {}
  }

  /// Clears all keys from secure storage.
  Future<void> clearAll() async {
    try {
      _cachedSession = null;
      await _storage.deleteAll();
    } catch (_) {}
  }

  /// Deletes stored token for a specific [userId] if known.
  Future<void> deleteToken(String userId) async {
    try {
      await _storage.delete(key: _tokenKey(userId));
      final activeUserId = await _storage.read(key: _activeUserIdKey);
      if (activeUserId == userId) {
        await _storage.delete(key: _activeUserIdKey);
        _cachedSession = null;
      }
    } catch (_) {}
  }
}

/// Global singleton [TokenStorage] shared across router guards and providers.
TokenStorage globalTokenStorage = TokenStorage();

/// Provider for the global [TokenStorage] instance.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return globalTokenStorage;
});

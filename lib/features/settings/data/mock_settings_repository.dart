import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// In-memory mock implementation of [SettingsRepository] isolating preferences per user.
///
/// Follows AGENTS.md §5 & §6: strictly user-isolated data, safe guest-to-account migration.
class MockSettingsRepository implements SettingsRepository {
  MockSettingsRepository({
    Map<String, AppSettings>? initialSettings,
    this.shouldFail = false,
  }) : _storage = initialSettings ?? <String, AppSettings>{};

  final Map<String, AppSettings> _storage;
  final bool shouldFail;

  @override
  Future<AppSettings> loadSettings(String userId) async {
    if (shouldFail) {
      throw StateError('Storage error: unable to load user settings.');
    }
    return _storage[userId] ?? const AppSettings();
  }

  @override
  Future<void> saveSettings(String userId, AppSettings settings) async {
    if (shouldFail) {
      throw StateError('Storage error: unable to persist user settings.');
    }
    _storage[userId] = settings;
  }

  @override
  Future<void> resetUserData(String userId) async {
    if (shouldFail) {
      throw StateError('Storage error: unable to reset user settings.');
    }
    _storage.remove(userId);
  }
}

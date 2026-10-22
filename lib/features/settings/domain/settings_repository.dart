import 'app_settings.dart';

/// Pure Dart repository interface for loading, persisting, and resetting user settings.
///
/// Follows AGENTS.md §2.2 & §6: strictly user-isolated by [userId], zero Flutter imports.
abstract interface class SettingsRepository {
  /// Loads settings for [userId]. Returns defaults if unconfigured.
  Future<AppSettings> loadSettings(String userId);

  /// Persists [settings] for [userId].
  Future<void> saveSettings(String userId, AppSettings settings);

  /// Resets all local stored preferences and user-specific state for [userId].
  Future<void> resetUserData(String userId);
}

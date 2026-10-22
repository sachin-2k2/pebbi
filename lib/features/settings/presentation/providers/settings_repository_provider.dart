import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_settings_repository.dart';
import '../../domain/settings_repository.dart';

/// Riverpod provider for [SettingsRepository].
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return MockSettingsRepository();
});

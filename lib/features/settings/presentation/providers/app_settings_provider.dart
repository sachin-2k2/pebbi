import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/app_settings.dart';

/// State notifier managing user application settings.
///
/// Follows AGENTS.md §2.3: watched at app root to govern theme, accent, and motion.
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier([super.initial = const AppSettings()]);

  /// Updates the accent colour identifier and updates theme listeners.
  void setAccentId(String accentId) {
    if (state.accentId != accentId) {
      state = state.copyWith(accentId: accentId);
    }
  }

  /// Toggles sound effects and audio preview playback.
  void setSoundEnabled(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
  }

  /// Toggles haptic feedback vibrations.
  void setHapticsEnabled(bool enabled) {
    state = state.copyWith(hapticsEnabled: enabled);
  }

  /// Toggles reduced motion animations.
  void setReduceMotion(bool reduce) {
    state = state.copyWith(reduceMotion: reduce);
  }

  /// Sets the custom text scale factor.
  void setTextScale(double scale) {
    state = state.copyWith(textScale: scale);
  }

  /// Toggles left-handed layout mode.
  void setLeftHanded(bool leftHanded) {
    state = state.copyWith(isLeftHanded: leftHanded);
  }
}

/// Global provider for application settings.
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
      return AppSettingsNotifier();
    });

/// Derived provider exposing the active accent [Color].
final accentColorProvider = Provider<Color>((ref) {
  final accentValue = ref.watch(
    appSettingsProvider.select((s) => s.accentColorValue),
  );
  return Color(accentValue);
});

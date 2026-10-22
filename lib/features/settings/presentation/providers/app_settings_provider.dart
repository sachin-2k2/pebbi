import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/app_settings.dart';
import '../../domain/hand_preference.dart';
import '../../domain/text_size_rules.dart';

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

  /// Sets the custom in-app text scale factor (snapped to nearest 0.05 step).
  void setTextScale(double scale) {
    final snapped = TextSizeRules.snapScale(scale);
    state = state.copyWith(textScale: snapped);
  }

  /// Toggles left-handed layout mode.
  void setLeftHanded(bool leftHanded) {
    state = state.copyWith(isLeftHanded: leftHanded);
  }

  /// Sets theme brightness mode ('light', 'dark', 'system').
  void setThemeMode(String mode) {
    if (state.themeMode != mode) {
      state = state.copyWith(themeMode: mode);
    }
  }

  /// Toggles display of romanization/transliteration helper lines.
  void setShowHelperLine(bool show) {
    state = state.copyWith(showHelperLine: show);
  }

  /// Toggles automatic phrase audio playback.
  void setAutoplay(bool autoplay) {
    state = state.copyWith(autoplay: autoplay);
  }

  /// Toggles speaking practice exercises vs self-check mode.
  void setSpeakingPracticeEnabled(bool enabled) {
    state = state.copyWith(speakingPracticeEnabled: enabled);
  }

  /// Toggles persistent captions in roleplay sessions.
  void setCaptionsAlwaysOn(bool captions) {
    state = state.copyWith(captionsAlwaysOn: captions);
  }

  /// Sets or clears user's optional first name.
  void setFirstName(String? name) {
    if (name == null || name.trim().isEmpty) {
      state = state.copyWith(clearFirstName: true);
    } else {
      state = state.copyWith(firstName: name.trim());
    }
  }

  /// Resets settings to default values.
  void resetToDefaults() {
    state = const AppSettings();
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

/// Derived provider exposing the active [ThemeMode].
final themeModeProvider = Provider<ThemeMode>((ref) {
  final mode = ref.watch(appSettingsProvider.select((s) => s.themeMode));
  switch (mode) {
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
    case 'light':
    default:
      return ThemeMode.light;
  }
});

/// Derived provider exposing in-app text scale multiplier.
final textScaleProvider = Provider<double>((ref) {
  return ref.watch(appSettingsProvider.select((s) => s.textScale));
});

/// Derived provider exposing whether left-handed mode is active.
final isLeftHandedProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider.select((s) => s.isLeftHanded));
});

/// Derived provider exposing user [HandPreference].
final handPreferenceProvider = Provider<HandPreference>((ref) {
  final isLeft = ref.watch(isLeftHandedProvider);
  return isLeft ? HandPreference.leftHanded : HandPreference.rightHanded;
});

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/presentation/providers/app_settings_provider.dart';

/// Service abstraction for triggering audio and haptic feedback during exercises.
///
/// Follows AGENTS.md §2.1 & §2.4: hides platform audio/haptics behind an interface
/// allowing seamless unit testing and settings enforcement.
abstract interface class AudioFeedbackService {
  /// Plays success sound and light haptic feedback.
  Future<void> playSuccess();

  /// Plays gentle error feedback (gentle sound and haptic).
  Future<void> playWrong();
}

/// Standard production implementation of [AudioFeedbackService].
class AppAudioFeedbackService implements AudioFeedbackService {
  const AppAudioFeedbackService({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;

  @override
  Future<void> playSuccess() async {
    if (hapticsEnabled) {
      await HapticFeedback.lightImpact();
    }
    if (soundEnabled) {
      // Audio playback hook (pre-recorded gentle chime in real app)
    }
  }

  @override
  Future<void> playWrong() async {
    if (hapticsEnabled) {
      await HapticFeedback.selectionClick();
    }
    if (soundEnabled) {
      // Audio playback hook (gentle muted boop, no harsh sound per spec)
    }
  }
}

/// Fake implementation of [AudioFeedbackService] for unit and widget tests.
class FakeAudioFeedbackService implements AudioFeedbackService {
  int successCount = 0;
  int wrongCount = 0;

  @override
  Future<void> playSuccess() async {
    successCount++;
  }

  @override
  Future<void> playWrong() async {
    wrongCount++;
  }

  void reset() {
    successCount = 0;
    wrongCount = 0;
  }
}

/// Riverpod provider for [AudioFeedbackService].
final audioFeedbackServiceProvider = Provider<AudioFeedbackService>((ref) {
  final sound = ref.watch(appSettingsProvider.select((s) => s.soundEnabled));
  final haptics = ref.watch(
    appSettingsProvider.select((s) => s.hapticsEnabled),
  );
  return AppAudioFeedbackService(soundEnabled: sound, hapticsEnabled: haptics);
});

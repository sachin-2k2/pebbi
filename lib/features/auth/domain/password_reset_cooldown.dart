import 'clock.dart';

/// Pure Dart domain model managing password reset resend cooldown and rate limits.
///
/// Follows AGENTS.md §2.2: Pure Dart rules and models with zero Flutter imports.
class PasswordResetCooldown {
  const PasswordResetCooldown({required this.clock, this.cooldownEndsAt});

  /// Default cooldown interval after requesting a password reset.
  ///
  /// TODO(question: the backend rate limit policy decides the exact cooldown window).
  static const int defaultCooldownSeconds = 60;

  final AppClock clock;
  final DateTime? cooldownEndsAt;

  /// Whether the cooldown period is currently active.
  bool get isInCooldown {
    if (cooldownEndsAt == null) return false;
    return clock.now().isBefore(cooldownEndsAt!);
  }

  /// Remaining seconds in the cooldown period, clamped at 0.
  int get remainingSeconds {
    if (cooldownEndsAt == null) return 0;
    final diffMs = cooldownEndsAt!.difference(clock.now()).inMilliseconds;
    if (diffMs <= 0) return 0;
    return (diffMs / 1000.0).ceil();
  }

  /// Whether a new reset link can be requested.
  bool get canResend => !isInCooldown;

  /// Returns a new instance with a fresh cooldown initiated from the current time.
  PasswordResetCooldown startNewCooldown({
    int seconds = defaultCooldownSeconds,
  }) {
    final endsAt = clock.now().add(Duration(seconds: seconds));
    return PasswordResetCooldown(clock: clock, cooldownEndsAt: endsAt);
  }

  /// Returns a new instance with the cooldown cleared.
  PasswordResetCooldown clear() {
    return PasswordResetCooldown(clock: clock, cooldownEndsAt: null);
  }
}

/// Reason why a speaking exercise transitioned to the self-check screen.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
enum SelfCheckReason {
  /// The microphone did not pick up speech, timed out, or low similarity.
  notHeard,

  /// User chose "I'd rather not speak right now".
  userChose,

  /// Microphone or speech recognition permission was denied by the user.
  permissionDenied,

  /// Speech recognizer is not available on device or locale unsupported.
  unavailable,

  /// User disabled "Speaking practice" in Settings.
  settingOff,

  /// Speaking is restricted by policy (e.g. minor COPPA restriction).
  policy,
}

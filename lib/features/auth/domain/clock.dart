/// Abstraction for system clock to allow deterministic testing of time-based logic.
///
/// Follows AGENTS.md §2.2: Pure Dart interface with zero Flutter imports.
abstract interface class AppClock {
  DateTime now();
}

/// Default system clock using standard [DateTime.now].
class SystemClock implements AppClock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

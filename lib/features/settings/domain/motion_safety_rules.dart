/// Pure Dart domain rules for motion reduction and animation safety.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
abstract final class MotionSafetyRules {
  /// Evaluates whether animations should be disabled/reduced.
  ///
  /// Returns true if EITHER the user explicitly toggled "Reduce motion" in-app
  /// OR the underlying operating system accessibility setting requests reduced motion.
  static bool shouldReduceMotion({
    required bool appSetting,
    required bool systemSetting,
  }) {
    return appSetting || systemSetting;
  }
}

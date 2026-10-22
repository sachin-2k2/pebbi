/// Pure Dart domain interface providing application version metadata.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
abstract interface class VersionInfo {
  /// The user-visible semantic version number (e.g. '1.0.0').
  String get appVersion;
}

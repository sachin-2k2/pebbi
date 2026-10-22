import '../domain/version_info.dart';

/// In-memory mock implementation of [VersionInfo] returning build-configured version.
///
/// Follows AGENTS.md §2.1: isolates version string access behind an interface.
class MockVersionInfo implements VersionInfo {
  const MockVersionInfo({this.version = '1.0.0'});

  final String version;

  @override
  String get appVersion => version;
}

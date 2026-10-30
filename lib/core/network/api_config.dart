import 'package:flutter/foundation.dart';
import 'api_mode.dart';

/// Environment and build-time network configuration.
///
/// Follows AGENTS.md §1 & §4:
/// - Environment configurations from build-time flags (`--dart-define`).
/// - Android emulator defaults to `10.0.2.2:8000`.
/// - Release builds strictly reject non-HTTPS URLs.
/// - Per-feature `ApiMode` switches (placement, auth, lessons).
class ApiConfig {
  ApiConfig({
    String? baseUrl,
    ApiMode? placementApiMode,
    ApiMode? authApiMode,
    ApiMode? lessonApiMode,
    bool isRelease = kReleaseMode,
  }) : baseUrl = _sanitizeBaseUrl(
         baseUrl ??
             const String.fromEnvironment(
               'API_BASE_URL',
               defaultValue:
                   'https://player-halo-ancient-speaker.trycloudflare.com',
             ),
       ),
       placementApiMode =
           placementApiMode ??
           ApiMode.fromString(
             const String.fromEnvironment(
               'PLACEMENT_API',
               defaultValue: 'real',
             ),
           ),
       authApiMode =
           authApiMode ??
           ApiMode.fromString(
             const String.fromEnvironment('AUTH_API', defaultValue: 'real'),
           ),
       lessonApiMode =
           lessonApiMode ??
           ApiMode.fromString(
             const String.fromEnvironment('LESSON_API', defaultValue: 'real'),
           ) {
    if (isRelease && !this.baseUrl.startsWith('https://')) {
      throw StateError(
        'Security Violation: Production release builds must use secure HTTPS endpoints. '
        'Refusing to initialize with cleartext URL: ${this.baseUrl}',
      );
    }
  }

  /// Base URL for backend APIs without trailing slash (e.g. `http://10.0.2.2:8000`).
  final String baseUrl;

  /// Operational API mode for placement quiz flow.
  final ApiMode placementApiMode;

  /// Operational API mode for authentication and user accounts.
  final ApiMode authApiMode;

  /// Operational API mode for lessons and path tracks.
  final ApiMode lessonApiMode;

  /// Global default instance created from active environment definitions.
  static ApiConfig? _instance;
  static ApiConfig get instance => _instance ??= ApiConfig();

  @visibleForTesting
  static void setTestInstance(ApiConfig? config) => _instance = config;

  static String _sanitizeBaseUrl(String url) {
    var trimmed = url.trim();
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}

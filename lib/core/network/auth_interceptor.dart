import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

/// Interceptor attaching JWT/Bearer tokens to authenticated HTTP requests.
///
/// Follows AGENTS.md §2 & §6:
/// - Security Rule: Uses an explicit allow-list for public routes.
/// - Matches by whole URL segments relative to the API base path.
/// - Never sends an `Authorization` header to public endpoints.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required TokenStorage tokenStorage, String? apiBasePath})
    : _tokenStorage = tokenStorage,
      _apiBasePath = _normalizeBasePath(apiBasePath);

  final TokenStorage _tokenStorage;
  final String _apiBasePath;

  /// Authoritative list of public path rules that must NOT receive auth headers.
  ///
  /// Can be cleanly extended in future tasks (e.g. password reset, OTP resend).
  static const List<PublicRouteRule> publicRouteRules = [
    // Placement endpoints (wildcard subtree)
    PublicRouteRule.subtree(['api', 'placement']),
    // Language catalogs (wildcard subtree)
    PublicRouteRule.subtree(['api', 'languages']),
    // Auth public actions (exact endpoints)
    PublicRouteRule.exact(['api', 'auth', 'register']),
    PublicRouteRule.exact(['api', 'auth', 'verify-otp']),
    PublicRouteRule.exact(['api', 'auth', 'login']),
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final uri = options.uri;

    if (isPublic(uri, basePath: _apiBasePath)) {
      // Ensure no Authorization header is present on public requests
      options.headers.remove('Authorization');
      return handler.next(options);
    }

    // Authenticated request: retrieve active token
    final session = await _tokenStorage.getActiveSession();
    if (session != null && session.token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${session.token}';
    }

    return handler.next(options);
  }

  /// Determines whether [uri] is a public route by comparing path segments.
  static bool isPublic(Uri uri, {String? basePath}) {
    var path = uri.path;

    if (basePath != null && basePath.isNotEmpty && path.startsWith(basePath)) {
      path = path.substring(basePath.length);
    }

    final segments = path
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList(growable: false);

    for (final rule in publicRouteRules) {
      if (rule.matches(segments)) return true;
    }

    return false;
  }

  static String _normalizeBasePath(String? path) {
    if (path == null || path.isEmpty) return '';
    var normalized = path.trim();
    if (!normalized.startsWith('/')) normalized = '/$normalized';
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}

/// Rule for matching public URL routes by segments.
class PublicRouteRule {
  const PublicRouteRule.exact(this.segments) : isSubtree = false;
  const PublicRouteRule.subtree(this.segments) : isSubtree = true;

  final List<String> segments;
  final bool isSubtree;

  bool matches(List<String> targetSegments) {
    if (isSubtree) {
      // Subtree requires target to have AT LEAST as many segments as rule,
      // plus at least one child segment (e.g. /api/placement/intro matches /api/placement,
      // but /api/placement alone does not match unless specified).
      if (targetSegments.length <= segments.length) return false;
      for (var i = 0; i < segments.length; i++) {
        if (targetSegments[i] != segments[i]) return false;
      }
      return true;
    } else {
      // Exact segment count and content must match identically
      if (targetSegments.length != segments.length) return false;
      for (var i = 0; i < segments.length; i++) {
        if (targetSegments[i] != segments[i]) return false;
      }
      return true;
    }
  }
}

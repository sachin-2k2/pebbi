import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/token_storage.dart';
import 'api_config.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';
import 'retry_interceptor.dart';

/// Central HTTP API Client built on [Dio].
///
/// Follows AGENTS.md §2 & §5:
/// - Connect timeout: 10s, receive timeout: 30s.
/// - Segment-based auth header attachment for authenticated endpoints.
/// - Redacted, body-free logging in debug mode only.
/// - Idempotent GET retries with exponential backoff.
class ApiClient {
  ApiClient({
    ApiConfig? config,
    TokenStorage? tokenStorage,
    HttpClientAdapter? adapter,
    Dio? dio,
  }) : config = config ?? ApiConfig.instance,
       tokenStorage = tokenStorage ?? TokenStorage() {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: this.config.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
            responseType: ResponseType.json,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              if (this.config.baseUrl.contains('ngrok'))
                'ngrok-skip-browser-warning': 'true',
            },
          ),
        );

    if (adapter != null) {
      _dio.httpClientAdapter = adapter;
    }

    _dio.interceptors.addAll([
      AuthInterceptor(tokenStorage: this.tokenStorage),
      RetryInterceptor(dio: _dio),
      LoggingPolicyInterceptor(),
    ]);
  }

  final ApiConfig config;
  final TokenStorage tokenStorage;
  late final Dio _dio;

  Dio get dio => _dio;

  /// Shorthand HTTP GET
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Shorthand HTTP POST
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

/// Riverpod provider for the central [ApiClient].
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenStorage: tokenStorage);
});

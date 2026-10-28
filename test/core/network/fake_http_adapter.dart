import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

/// Recorded HTTP request for test assertions.
class RecordedRequest {
  const RecordedRequest({
    required this.method,
    required this.uri,
    required this.headers,
    this.body,
  });

  final String method;
  final Uri uri;
  final Map<String, dynamic> headers;
  final dynamic body;

  String get path => uri.path;
}

/// Fake Dio [HttpClientAdapter] that records calls and dispatches mock responses.
class FakeHttpClientAdapter implements HttpClientAdapter {
  final List<RecordedRequest> recordedRequests = [];
  final Map<String, ResponseBody Function(RequestOptions options)> _handlers =
      {};
  DioException Function(RequestOptions options)? _exceptionHandler;

  /// Registers a response handler for an exact path or prefix.
  void on(String path, ResponseBody Function(RequestOptions options) handler) {
    _handlers[path] = handler;
  }

  /// Convenience method to register a JSON string response.
  void onJson(
    String path,
    String jsonString, {
    int statusCode = 200,
    Map<String, List<String>>? headers,
  }) {
    on(path, (options) {
      final utf8Bytes = utf8.encode(jsonString);
      return ResponseBody.fromBytes(
        utf8Bytes,
        statusCode,
        headers:
            headers ??
            {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
      );
    });
  }

  /// Registers an exception to be thrown on the next request(s).
  void throwException(DioException Function(RequestOptions options) handler) {
    _exceptionHandler = handler;
  }

  /// Clears recorded requests, handlers, and exception triggers.
  void reset() {
    recordedRequests.clear();
    _handlers.clear();
    _exceptionHandler = null;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    recordedRequests.add(
      RecordedRequest(
        method: options.method,
        uri: options.uri,
        headers: Map.unmodifiable(options.headers),
        body: options.data,
      ),
    );

    if (_exceptionHandler != null) {
      throw _exceptionHandler!(options);
    }

    final path = options.uri.path;
    for (final entry in _handlers.entries) {
      if (path == entry.key || path.endsWith(entry.key)) {
        return entry.value(options);
      }
    }

    // Default 404 response
    final notFoundBytes = utf8.encode(
      '{"detail": "Not found in fake adapter"}',
    );
    return ResponseBody.fromBytes(
      notFoundBytes,
      404,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

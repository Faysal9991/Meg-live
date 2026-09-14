import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_logger.dart';

/// Creates a Dio client with consistent debug logging for every API request.
Dio createApiDio([BaseOptions? options]) {
  return configureApiDio(Dio(options));
}

/// Adds API logging to an injected Dio client and returns the same instance.
///
/// This is idempotent, so callers can safely configure a client more than once.
Dio configureApiDio(Dio dio) {
  if (kDebugMode &&
      !dio.interceptors.any((item) => item is ApiLoggingInterceptor)) {
    dio.interceptors.add(ApiLoggingInterceptor());
  }
  return dio;
}

/// Logs Dio requests, responses, failures, and elapsed request time.
class ApiLoggingInterceptor extends Interceptor {
  static const String _stopwatchKey = 'doyel_api_logger_stopwatch';
  static const String _requestIdKey = 'doyel_api_logger_request_id';
  static int _requestSequence = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId = _nextRequestId();
    options.extra[_stopwatchKey] = Stopwatch()..start();
    options.extra[_requestIdKey] = requestId;

    ApiLogger.hit(
      requestId: requestId,
      method: options.method,
      url: _urlWithoutQuery(options.uri),
      query: _queryForLog(options.uri),
      headers: Map<String, dynamic>.from(options.headers),
      body: _bodyForLog(options.data),
    );

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    ApiLogger.response(
      requestId: _requestId(request),
      method: request.method,
      url: _urlWithoutQuery(request.uri),
      statusCode: response.statusCode,
      data: _bodyForLog(response.data),
      headers: response.headers.map,
      duration: _elapsed(request),
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    ApiLogger.error(
      requestId: _requestId(request),
      method: request.method,
      url: _urlWithoutQuery(request.uri),
      error: err,
      stackTrace: err.stackTrace,
      statusCode: err.response?.statusCode,
      data: _bodyForLog(err.response?.data),
      headers: err.response?.headers.map,
      duration: _elapsed(request),
    );

    handler.next(err);
  }

  static Duration? _elapsed(RequestOptions options) {
    final stopwatch = options.extra.remove(_stopwatchKey);
    if (stopwatch is! Stopwatch) return null;
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  static String _requestId(RequestOptions options) {
    return options.extra.remove(_requestIdKey)?.toString() ?? 'unknown';
  }

  static String _nextRequestId() {
    _requestSequence = (_requestSequence + 1) % 0x7fffffff;
    final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    return '$time-${_requestSequence.toRadixString(36)}';
  }

  static String _urlWithoutQuery(Uri uri) {
    final url = uri
        .replace(queryParameters: const <String, String>{})
        .toString();
    return url.endsWith('?') ? url.substring(0, url.length - 1) : url;
  }

  static Map<String, dynamic>? _queryForLog(Uri uri) {
    if (!uri.hasQuery) return null;

    return uri.queryParametersAll.map(
      (key, values) => MapEntry<String, dynamic>(
        key,
        values.length == 1 ? values.single : values,
      ),
    );
  }

  static dynamic _bodyForLog(dynamic data) {
    if (data is FormData) {
      return <String, dynamic>{
        'fields': [
          for (final field in data.fields) {field.key: field.value},
        ],
        'files': [
          for (final file in data.files)
            <String, dynamic>{
              'field': file.key,
              'filename': file.value.filename,
              'content_type': file.value.contentType?.toString(),
              'length': file.value.length,
            },
        ],
      };
    }
    if (data is Uint8List) return '<${data.length} bytes>';
    if (data is Stream) return '<stream>';
    return data;
  }
}

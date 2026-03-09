import 'dart:convert';
import 'package:flutter/foundation.dart';

class ApiLogger {
  static const int _maxLogLength = 1200;

  // ANSI colors
  static const String reset = '\x1B[0m';
  static const String green = '\x1B[32m';
  static const String cyan = '\x1B[36m';
  static const String yellow = '\x1B[33m';
  static const String red = '\x1B[31m';
  static const String purple = '\x1B[35m';
  static const String blue = '\x1B[34m';
  static const String bold = '\x1B[1m';

  static void hit({
    required String method,
    required String url,
    dynamic body,
    Map<String, dynamic>? query,
  }) {
    if (!kDebugMode) return;

    debugPrint('$bold$blue🚀 [API HIT] $method $url$reset');

    if (query != null && query.isNotEmpty) {
      debugPrint('$cyan🔎 QUERY:${reset} ${_clip(_stringify(query))}');
    }

    if (body != null) {
      debugPrint('$yellow📦 REQUEST:${reset} ${_clip(_stringify(body))}');
    }
  }

  static void response({
    required String method,
    required String url,
    required int? statusCode,
    dynamic data,
  }) {
    if (!kDebugMode) return;

    debugPrint('$bold$green✅ [API RESPONSE] $method $url status=${statusCode ?? 'null'}$reset');

    if (data != null) {
      debugPrint('$purple📄 DATA:${reset} ${_clip(_stringify(data))}');
    }
  }

  static void error({
    required String method,
    required String url,
    required Object error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    debugPrint('$bold$red❌ [API ERROR] $method $url$reset');
    debugPrint('$red⚠️ ERROR: $error$reset');

    if (stackTrace != null) {
      debugPrint('$red📛 STACK:${reset} ${_clip(stackTrace.toString())}');
    }
  }

  static String _stringify(dynamic value) {
    try {
      if (value is String) return value;
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  static String _clip(String value) {
    if (value.length <= _maxLogLength) return value;
    return '${value.substring(0, _maxLogLength)}...<truncated>';
  }
}
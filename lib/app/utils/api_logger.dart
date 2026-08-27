import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Lightweight, dependency-free API logger for local development.
///
/// Production safety:
/// - Logging is completely disabled outside [kDebugMode].
/// - Common credential fields are automatically redacted.
/// - Long payloads are chunked instead of truncated so complete debug
///   responses remain visible without hitting platform log-size limits.
class ApiLogger {
  ApiLogger._();

  static const int _chunkSize = 800;
  static const String _redacted = '<redacted>';

  // ANSI colors. Keep these local to the logger so UI colors remain separate
  // from terminal/debug-console presentation concerns.
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _dim = '\x1B[2m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';

  static const Set<String> _sensitiveKeys = {
    'password',
    'oldpassword',
    'newpassword',
    'confirmpassword',
    'passwordconfirmation',
    'token',
    'accesstoken',
    'refreshtoken',
    'authorization',
    'apikey',
    'xapikey',
    'secret',
    'clientsecret',
    'otp',
    'pin',
    'cvv',
  };

  static void hit({
    required String method,
    required String url,
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) {
    if (!kDebugMode) return;

    _header('🚀 API REQUEST', _blue);
    _field('TIME', _timestamp(), _dim);
    _field('METHOD', method.toUpperCase(), _cyan);
    _field('URL', url, _white);

    if (query != null && query.isNotEmpty) {
      _payload('QUERY', query, _cyan);
    }

    if (headers != null && headers.isNotEmpty) {
      _payload('HEADERS', headers, _yellow);
    }

    if (body != null) {
      _payload('BODY', body, _yellow);
    }

    _footer(_blue);
  }

  static void response({
    required String method,
    required String url,
    required int? statusCode,
    dynamic data,
    Map<String, dynamic>? headers,
    Duration? duration,
  }) {
    if (!kDebugMode) return;

    final statusColor = _statusColor(statusCode);
    _header('✅ API RESPONSE', _green);
    _field('TIME', _timestamp(), _dim);
    _field('METHOD', method.toUpperCase(), _cyan);
    _field('URL', url, _white);
    _field('STATUS', statusCode?.toString() ?? 'null', statusColor);

    if (duration != null) {
      _field('DURATION', '${duration.inMilliseconds} ms', _magenta);
    }

    if (headers != null && headers.isNotEmpty) {
      _payload('HEADERS', headers, _cyan);
    }

    if (data != null) {
      _payload('DATA', data, _magenta);
    }

    _footer(_green);
  }

  static void error({
    required String method,
    required String url,
    required Object error,
    StackTrace? stackTrace,
    int? statusCode,
    dynamic data,
  }) {
    if (!kDebugMode) return;

    _header('❌ API ERROR', _red);
    _field('TIME', _timestamp(), _dim);
    _field('METHOD', method.toUpperCase(), _cyan);
    _field('URL', url, _white);

    if (statusCode != null) {
      _field('STATUS', statusCode.toString(), _statusColor(statusCode));
    }

    _payload('ERROR', error.toString(), _red);

    if (data != null) {
      _payload('DATA', data, _yellow);
    }

    if (stackTrace != null) {
      _payload('STACK TRACE', stackTrace.toString(), _red);
    }

    _footer(_red);
  }

  /// General-purpose debug information for network-adjacent flows such as
  /// sockets, retries, and connection state changes.
  static void info(String message, {String? tag, dynamic data}) {
    if (!kDebugMode) return;

    _header(
      'ℹ️ ${tag?.trim().isNotEmpty == true ? tag!.trim() : 'INFO'}',
      _cyan,
    );
    _field('TIME', _timestamp(), _dim);
    _payload('MESSAGE', message, _cyan);
    if (data != null) {
      _payload('DATA', data, _magenta);
    }
    _footer(_cyan);
  }

  static void warning(String message, {String? tag, dynamic data}) {
    if (!kDebugMode) return;

    _header(
      '⚠️ ${tag?.trim().isNotEmpty == true ? tag!.trim() : 'WARNING'}',
      _yellow,
    );
    _field('TIME', _timestamp(), _dim);
    _payload('MESSAGE', message, _yellow);
    if (data != null) {
      _payload('DATA', data, _magenta);
    }
    _footer(_yellow);
  }

  static void _header(String title, String color) {
    _write(
      '$_bold$color╔══════════════════════════════════════════════════════════════$_reset',
    );
    _write('$_bold$color║ $title$_reset');
    _write(
      '$_bold$color╠══════════════════════════════════════════════════════════════$_reset',
    );
  }

  static void _footer(String color) {
    _write(
      '$_bold$color╚══════════════════════════════════════════════════════════════$_reset',
    );
  }

  static void _field(String label, String value, String valueColor) {
    _write('$_bold$_blue║ $label:$_reset $valueColor$value$_reset');
  }

  static void _payload(String label, dynamic value, String color) {
    final formatted = _stringify(_sanitize(value));
    _write('$_bold$_blue║ $label:$_reset');

    for (final line in formatted.split('\n')) {
      _write('$color║   $line$_reset');
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

  static dynamic _sanitize(dynamic value) {
    if (value is Map) {
      final sanitized = <String, dynamic>{};
      value.forEach((dynamic key, dynamic item) {
        final keyString = key.toString();
        sanitized[keyString] = _isSensitiveKey(keyString)
            ? _redacted
            : _sanitize(item);
      });
      return sanitized;
    }

    if (value is Iterable) {
      return value.map<dynamic>(_sanitize).toList(growable: false);
    }

    return value;
  }

  static bool _isSensitiveKey(String key) {
    final normalized = key
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');

    return _sensitiveKeys.contains(normalized) ||
        normalized.endsWith('password') ||
        normalized.endsWith('token') ||
        normalized.endsWith('secret') ||
        normalized.endsWith('apikey');
  }

  static String _statusColor(int? statusCode) {
    if (statusCode == null) return _yellow;
    if (statusCode >= 200 && statusCode < 300) return _green;
    if (statusCode >= 300 && statusCode < 400) return _cyan;
    if (statusCode >= 400 && statusCode < 500) return _yellow;
    return _red;
  }

  static String _timestamp() => DateTime.now().toIso8601String();

  /// Android/logcat and some IDE consoles can truncate very long single log
  /// entries. Emit bounded chunks so the complete payload remains readable.
  static void _write(String message) {
    if (message.isEmpty) {
      debugPrint('');
      return;
    }

    var start = 0;
    while (start < message.length) {
      final end = (start + _chunkSize < message.length)
          ? start + _chunkSize
          : message.length;
      debugPrint(message.substring(start, end));
      start = end;
    }
  }
}

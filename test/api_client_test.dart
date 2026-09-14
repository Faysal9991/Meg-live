import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:doyel_live/app/utils/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.statusCode = 200});

  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode({'token': 'response-secret', 'message': 'request completed'}),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        'set-cookie': ['session=cookie-secret'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('configureApiDio installs the logger only once', () {
    final dio = Dio();

    expect(configureApiDio(dio), same(dio));
    configureApiDio(dio);

    expect(dio.interceptors.whereType<ApiLoggingInterceptor>(), hasLength(1));
  });

  test('logs a complete request cycle while redacting credentials', () async {
    final messages = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => messages.add(message ?? '');
    addTearDown(() => debugPrint = originalDebugPrint);

    final dio = createApiDio()..httpClientAdapter = _FakeAdapter();
    await dio.post<dynamic>(
      'https://example.test/profile',
      queryParameters: {'page': 2, 'token': 'query-secret'},
      data: {'display_name': 'Doyel user', 'password': 'body-secret'},
      options: Options(
        headers: {
          'Authorization': 'Token header-secret',
          'X-Api-Key': 'api-key-secret',
        },
      ),
    );

    final output = messages.join('\n');
    expect(output, contains('API REQUEST'));
    expect(output, contains('API RESPONSE'));
    expect(output, contains('REQUEST ID'));
    expect(output, contains('https://example.test/profile'));
    expect(output, contains('Doyel user'));
    expect(output, contains('request completed'));
    expect(output, contains('DURATION'));
    expect(output, contains('<redacted>'));
    expect(output, isNot(contains('query-secret')));
    expect(output, isNot(contains('body-secret')));
    expect(output, isNot(contains('header-secret')));
    expect(output, isNot(contains('api-key-secret')));
    expect(output, isNot(contains('response-secret')));
    expect(output, isNot(contains('cookie-secret')));
  });

  test('logs failed responses with status and duration', () async {
    final messages = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => messages.add(message ?? '');
    addTearDown(() => debugPrint = originalDebugPrint);

    final dio = createApiDio()
      ..httpClientAdapter = _FakeAdapter(statusCode: 500);

    await expectLater(
      dio.get<dynamic>(
        'https://example.test/failure',
        queryParameters: {'token': 'failed-query-secret'},
        options: Options(
          headers: {'Authorization': 'Token failed-header-secret'},
        ),
      ),
      throwsA(isA<DioException>()),
    );

    final output = messages.join('\n');
    expect(output, contains('API ERROR'));
    expect(output, contains('500'));
    expect(output, contains('DURATION'));
    expect(output, isNot(contains('response-secret')));
    expect(output, isNot(contains('cookie-secret')));
    expect(output, isNot(contains('failed-query-secret')));
    expect(output, isNot(contains('failed-header-secret')));
  });
}

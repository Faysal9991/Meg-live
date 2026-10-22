import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/auth/services/google_auth_service.dart';
import 'package:doyel_live/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

const _identity = GoogleLoginIdentity(
  id: 'google-user',
  email: 'user@example.test',
  idToken: 'id-token',
);

class _Google extends GoogleAuthService {
  Future<GoogleLoginIdentity> Function() result = () async => _identity;
  int calls = 0;

  @override
  Future<GoogleLoginIdentity> authenticate() {
    calls++;
    return result();
  }
}

class _Backend implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int status = 403;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({
        'token': 'app-token',
        'profile': {
          'user': {'uid': 999},
          'full_name': 'Test User',
        },
      }),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _Auth extends AuthController {
  _Auth(_Google google, _Backend backend)
    : super(
        googleAuth: google,
        googleLoginDio: Dio()..httpClientAdapter = backend,
      );

  @override
  void initialize() {}

  @override
  Future<String> getUniqueDeviceId() async => 'device-test';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Google google;
  late _Backend backend;
  late _Auth auth;
  setUp(() {
    Get.testMode = true;
    google = _Google();
    backend = _Backend();
    auth = _Auth(google, backend);
    Get.put<AuthController>(auth);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/shared_preferences'),
          (call) async => call.method == 'getAll' ? <String, Object>{} : true,
        );
  });
  tearDown(Get.reset);

  Future<void> openLogin(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: Text('Landing')),
        getPages: [
          GetPage(
            name: '/login-test',
            page: () => const Scaffold(body: Text('Login screen')),
          ),
          GetPage(
            name: Routes.NAV,
            page: () => const Scaffold(body: Text('Signed in')),
          ),
        ],
      ),
    );
    Get.toNamed('/login-test');
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets(
    'duplicate taps share one sign-in and rejection keeps the login route',
    (tester) async {
      await openLogin(tester);
      final picker = Completer<GoogleLoginIdentity>();
      google.result = () => picker.future;
      final login = auth.tryToSignInWithGoogle();
      await auth.tryToSignInWithGoogle();
      expect(auth.authLoading.value, isTrue);
      expect(google.calls, 1);
      picker.complete(_identity);
      await tester.pumpAndSettle();
      await login;
      expect(auth.authLoading.value, isFalse);
      expect(backend.requests, hasLength(1));
      expect(backend.requests.single.data['server_auth_code'], 'id-token');
      expect(
        backend.requests.single.queryParameters['device_id'],
        'device-test',
      );
      expect(find.text('Login screen'), findsOneWidget);
      await finish(tester);
    },
  );

  testWidgets(
    'logs OAuth audience without exposing ID tokens when backend rejects login',
    (tester) async {
      await openLogin(tester);
      const audience =
          '1028099754767-b9nvqcl8egtdevcoegjmkcmffj6he59i.apps.googleusercontent.com';
      final payload = base64Url.encode(
        utf8.encode(
          jsonEncode({'aud': audience, 'email': 'private@example.test'}),
        ),
      );
      final idToken = 'header.$payload.signature';
      google.result = () async => GoogleLoginIdentity(
        id: 'google-user',
        email: 'user@example.test',
        idToken: idToken,
      );
      final originalDebugPrint = debugPrint;
      final logs = <String>[];
      debugPrint = (message, {wrapWidth}) {
        if (message != null) logs.add(message);
      };
      try {
        final login = auth.tryToSignInWithGoogle();
        await tester.pumpAndSettle();
        await login;
      } finally {
        debugPrint = originalDebugPrint;
      }
      await tester.pumpAndSettle();
      expect(
        logs,
        contains(
          '[GOOGLE-AUTH] Google returned an ID token for audience $audience',
        ),
      );
      expect(logs, contains('[GOOGLE-AUTH] Backend rejected login: HTTP 403'));
      expect(logs.join('\n'), isNot(contains(idToken)));
      expect(logs.join('\n'), isNot(contains('private@example.test')));
      expect(backend.requests.single.data['server_auth_code'], idToken);
      expect(find.text('Login screen'), findsOneWidget);
      await finish(tester);
    },
  );

  testWidgets(
    'missing ID token never reaches backend and releases loading state',
    (tester) async {
      await openLogin(tester);
      google.result = () async => const GoogleLoginIdentity(
        id: 'google-user',
        email: 'user@example.test',
        idToken: null,
      );
      await auth.tryToSignInWithGoogle();
      await tester.pumpAndSettle();
      expect(backend.requests, isEmpty);
      expect(auth.authLoading.value, isFalse);
      expect(find.text('Login screen'), findsOneWidget);
      await finish(tester);
    },
  );

  testWidgets(
    'canceling the picker keeps login available without an error banner',
    (tester) async {
      await openLogin(tester);
      google.result = () async => throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
      );
      await auth.tryToSignInWithGoogle();
      await tester.pumpAndSettle();
      expect(auth.authLoading.value, isFalse);
      expect(backend.requests, isEmpty);
      expect(find.byType(GetSnackBar), findsNothing);
      expect(find.text('Login screen'), findsOneWidget);
      await finish(tester);
    },
  );

  testWidgets(
    'successful backend login persists the session before navigation',
    (tester) async {
      await openLogin(tester);
      backend.status = 201;
      final login = auth.tryToSignInWithGoogle();
      await tester.pumpAndSettle();
      await login;
      expect(auth.token.value, 'app-token');
      expect(auth.profile.value.user?.uid, 999);
      expect(
        auth.preferences.getString('token', defaultValue: '').getValue(),
        'app-token',
      );
      expect(auth.authLoading.value, isFalse);
      expect(find.text('Signed in'), findsOneWidget);
      await finish(tester);
    },
  );
}

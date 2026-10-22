import 'package:doyel_live/app/modules/auth/services/google_auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart'
    as platform;

class _GooglePlatform extends platform.GoogleSignInPlatform {
  final initializations = <platform.InitParameters>[];
  int authentications = 0;
  bool failInitialization = true;

  @override
  Future<void> init(platform.InitParameters params) async {
    initializations.add(params);
    if (failInitialization) {
      throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
      );
    }
  }

  @override
  Future<platform.AuthenticationResults> authenticate(
    platform.AuthenticateParameters params,
  ) async {
    authentications++;
    return const platform.AuthenticationResults(
      user: platform.GoogleSignInUserData(
        id: 'google-user',
        email: 'user@example.test',
        displayName: 'Test User',
        photoUrl: 'https://example.test/avatar.png',
      ),
      authenticationTokens: platform.AuthenticationTokenData(
        idToken: 'id-token',
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unexpected Google API: ${invocation.memberName}');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'uses imported OAuth clients and retries initialization on iOS and Android',
    () async {
      final originalPlatform = platform.GoogleSignInPlatform.instance;
      final google = _GooglePlatform();
      platform.GoogleSignInPlatform.instance = google;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() {
        platform.GoogleSignInPlatform.instance = originalPlatform;
        debugDefaultTargetPlatformOverride = null;
      });

      final service = GoogleAuthService();
      const override = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
      final expectedServerClient = override.isEmpty
          ? '1028099754767-b9nvqcl8egtdevcoegjmkcmffj6he59i.apps.googleusercontent.com'
          : override;
      await expectLater(
        service.authenticate(),
        throwsA(isA<GoogleSignInException>()),
      );
      expect(google.authentications, 0);
      expect(
        google.initializations.single.clientId,
        '1028099754767-0r0lctguquljs8lkah5qa6ef1kths8cl.apps.googleusercontent.com',
      );
      expect(
        google.initializations.single.serverClientId,
        expectedServerClient,
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await expectLater(
        service.authenticate(),
        throwsA(isA<GoogleSignInException>()),
      );
      expect(google.initializations.last.clientId, isNull);
      expect(google.initializations.last.serverClientId, expectedServerClient);

      google.failInitialization = false;
      final identity = await service.authenticate();
      expect(identity.id, 'google-user');
      expect(identity.email, 'user@example.test');
      expect(identity.idToken, 'id-token');
      expect(identity.displayName, 'Test User');
      expect(identity.photoUrl, 'https://example.test/avatar.png');

      await service.authenticate();
      expect(google.initializations, hasLength(3));
      expect(google.authentications, 2);
    },
  );
}

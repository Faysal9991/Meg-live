import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLoginIdentity {
  const GoogleLoginIdentity({
    required this.id,
    required this.email,
    required this.idToken,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String? idToken;
  final String? displayName;
  final String? photoUrl;
}

/// Initializes on demand so a Google configuration error cannot prevent app
/// startup. Android reads its web OAuth client from google-services.json unless
/// an explicit backend audience is supplied with GOOGLE_SERVER_CLIENT_ID.
class GoogleAuthService {
  static final instance = GoogleAuthService();
  static Future<void>? _initialization;
  static const _serverClientIdOverride = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const _nonAndroidServerClientId =
      '976789308527-a7ie4kfg7le4ae4aoasdpgfafg9pqcga.apps.googleusercontent.com';

  Future<void> _initialize() async {
    final serverClientId = _serverClientIdOverride.isNotEmpty
        ? _serverClientIdOverride
        : defaultTargetPlatform == TargetPlatform.android
        ? null
        : _nonAndroidServerClientId;
    try {
      await (_initialization ??= GoogleSignIn.instance.initialize(
        serverClientId: serverClientId,
      ));
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  Future<GoogleLoginIdentity> authenticate() async {
    await _initialize();
    final account = await GoogleSignIn.instance.authenticate();
    return GoogleLoginIdentity(
      id: account.id,
      email: account.email,
      idToken: account.authentication.idToken,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
    );
  }
}

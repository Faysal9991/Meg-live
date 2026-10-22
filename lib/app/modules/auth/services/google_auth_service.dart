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
/// startup. Uses Max Live's active Google OAuth registration, which is separate
/// from its Firebase project. GOOGLE_SERVER_CLIENT_ID can override the audience.
class GoogleAuthService {
  static final instance = GoogleAuthService();
  static Future<void>? _initialization;
  static const _serverClientIdOverride = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const defaultServerClientId =
      '1028099754767-b9nvqcl8egtdevcoegjmkcmffj6he59i.apps.googleusercontent.com';
  static const _iosClientId =
      '1028099754767-0r0lctguquljs8lkah5qa6ef1kths8cl.apps.googleusercontent.com';

  Future<void> _initialize() async {
    final serverClientId = _serverClientIdOverride.isNotEmpty
        ? _serverClientIdOverride
        : defaultServerClientId;
    try {
      await (_initialization ??= GoogleSignIn.instance.initialize(
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? _iosClientId
            : null,
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

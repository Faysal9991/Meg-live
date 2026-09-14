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
/// startup. The web OAuth client is supplied explicitly because the Firebase
/// configuration does not contain OAuth clients for the authentication project.
class GoogleAuthService {
  static final instance = GoogleAuthService();
  static Future<void>? _initialization;
 static const _serverClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue:
      '976789308527-a7ie4kfg7le4ae4aoasdpgfafg9pqcga.apps.googleusercontent.com',
);
  Future<void> _initialize() async {
    try {
      await (_initialization ??= GoogleSignIn.instance.initialize(
        serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
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

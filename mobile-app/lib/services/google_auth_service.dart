import 'package:google_sign_in/google_sign_in.dart';

import '../config/google_auth_config.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: GoogleAuthConfig.serverClientId,
  );

  static Future<String?> signInAndGetIdToken() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }
}

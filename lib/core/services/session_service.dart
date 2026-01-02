import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/profile/application/user_profile_service.dart';

import 'current_user_service.dart';

class SessionService {
  SessionService._internal();
  static final SessionService instance = SessionService._internal();

  Future<void> signOut() async {
    await _signOutFirebaseProviders();
    await clearLocalState();
  }

  Future<void> clearLocalState() async {
    CurrentUserService.instance.clearCache();
    UserProfileService.instance.reset();
    await PersonalPlaylistService.instance.reset();
  }

  Future<void> _signOutFirebaseProviders() async {
    final futures = <Future<void>>[
      FirebaseAuth.instance.signOut(),
    ];
    // Ensure Google users can switch accounts on the next sign-in attempt.
    futures.add(_googleSignIn().signOut());
    await Future.wait(futures);
  }

  GoogleSignIn _googleSignIn() {
    return kIsWeb
        ? GoogleSignIn(
            clientId:
                '988257088468-atmtio8368tq3u9aptftbqiaebppek32.apps.googleusercontent.com',
          )
        : GoogleSignIn();
  }
}

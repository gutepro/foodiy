import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  Future<void> signInWithGoogle();

  Future<void> signInWithApple();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();
}

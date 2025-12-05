abstract class AuthService {
  Future<void> signInWithGoogle();

  Future<void> signInWithApple();

  Future<void> signOut();
}

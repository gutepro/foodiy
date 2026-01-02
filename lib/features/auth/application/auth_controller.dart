import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authService);

  final AuthService _authService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> signInWithGoogle() => _run(_authService.signInWithGoogle);

  Future<void> signInWithApple() => _run(_authService.signInWithApple);

  Future<void> signInWithEmail(String email, String password) =>
      _run(() => _authService.signInWithEmail(email: email, password: password));

  Future<UserCredential> signUpWithEmail(String email, String password) =>
      _runWithResult(
        () => _authService.signUpWithEmail(email: email, password: password),
      );

  Future<void> signOut() => _authService.signOut();

  Future<void> _run(Future<void> Function() action) async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      await action();
    } finally {
      _setLoading(false);
    }
  }

  Future<T> _runWithResult<T>(Future<T> Function() action) async {
    if (_isLoading) throw StateError('Already loading');
    _setLoading(true);
    try {
      return await action();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }
}

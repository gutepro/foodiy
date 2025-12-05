import 'package:flutter/foundation.dart';

import '../domain/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authService);

  final AuthService _authService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> signInWithGoogle() => _run(_authService.signInWithGoogle);

  Future<void> signInWithApple() => _run(_authService.signInWithApple);

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

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }
}

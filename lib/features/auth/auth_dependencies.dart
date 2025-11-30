import 'application/auth_controller.dart';
import 'data/firebase_auth_service.dart';
import 'domain/auth_service.dart';

final AuthService _authService = FirebaseAuthService();

AuthController createAuthController() => AuthController(_authService);

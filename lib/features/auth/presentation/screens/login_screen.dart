import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/shared/widgets/foodiy_logo.dart';
import 'package:foodiy/features/legal/presentation/screens/legal_document_screen.dart';

import '../../auth_dependencies.dart';
import '../../application/auth_controller.dart';
import '../../data/firebase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          'Legal',
          style: theme.textTheme.labelLarge,
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LegalDocumentScreen(
                  title: 'Terms of Use',
                  assetPath: 'assets/legal/terms_of_use_en.md',
                ),
              ),
            );
          },
          child: const Text('Terms of Use'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LegalDocumentScreen(
                  title: 'Privacy Policy',
                  assetPath: 'assets/legal/privacy_policy_en.md',
                ),
              ),
            );
          },
          child: const Text('Privacy Policy'),
        ),
      ],
    );
  }
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final AuthController _authController;
  String? _devDiagnostics;
  String? _lastGoogleErrorCode;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _authController = createAuthController()..addListener(_onAuthStateChanged);
    if (kDebugMode) {
      _refreshDevDiagnostics();
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthStateChanged);
    _authController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();
    try {
      await _authController.signInWithGoogle();
      _lastGoogleErrorCode = null;
      if (kDebugMode) {
        await _refreshDevDiagnostics();
      }
      await _completeAuthSuccess();
    } on GoogleSignInFailure catch (error, stackTrace) {
      debugPrint('GoogleSignInFailure(${error.code}): ${error.message}\n$stackTrace');
      setState(() {
        _lastGoogleErrorCode = error.code;
      });
      if (kDebugMode) {
        await _refreshDevDiagnostics();
      }
      _showGoogleSignInError(error);
    } catch (error, stackTrace) {
      debugPrint('GoogleSignIn error: $error\n$stackTrace');
      _showSnack('Sign in failed: ${error.toString()}');
    }
  }

  Future<void> _handleAppleSignIn() async {
    await _handleAuthAction(_authController.signInWithApple);
  }

  Future<void> _handleAuthAction(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();
    try {
      await action();
      await _completeAuthSuccess();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed: ${error.toString()}'),
        ),
      );
    }
  }

  Future<void> _handleEmailSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Please enter a valid email.');
      return;
    }
    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters.');
      return;
    }
    debugPrint('[AUTH_EMAIL_SIGNIN] start email=$email');
    try {
      await _authController.signInWithEmail(email, password);
      if (!mounted) return;
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        debugPrint('[AUTH_EMAIL_SIGNIN] not verified; redirecting');
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        context.go(AppRoutes.verifyEmail);
        return;
      }
      await _completeAuthSuccess();
      debugPrint('[AUTH_EMAIL_SIGNIN] success');
    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH_EMAIL_SIGNIN] error=${e.code}');
      _showSnack(_mapAuthError(e.code));
    } catch (e) {
      debugPrint('[AUTH_EMAIL_SIGNIN] error=$e');
      _showSnack('Sign in failed. Please try again.');
    }
  }

  Future<void> _completeAuthSuccess() async {
    await CurrentUserService.instance.refreshFromFirebase();
    if (!mounted) return;
    // TODO: Replace with auth gate that listens to FirebaseAuth authStateChanges.
    context.go(AppRoutes.home);
  }

  void _showGoogleSignInError(GoogleSignInFailure error) {
    String message;
    SnackBarAction? action;
    switch (error.code) {
      case 'no_network':
        message = 'No internet connection. Please try again.';
        action = SnackBarAction(label: 'Retry', onPressed: _handleGoogleSignIn);
        break;
      case 'api_exception_7':
        message =
            'Google sign-in failed. Please update Google Play services and try again.';
        action = SnackBarAction(label: 'Retry', onPressed: _handleGoogleSignIn);
        break;
      case 'play_services_updating':
        message = 'Google Play Services is updating. Try again shortly.';
        action = SnackBarAction(label: 'Retry', onPressed: _handleGoogleSignIn);
        break;
      case 'play_services_missing':
      case 'play_services_unavailable':
        message =
            'Google Play Services required. Use a Google Play emulator or a real device.';
        action = SnackBarAction(label: 'Retry', onPressed: _handleGoogleSignIn);
        break;
      case 'cancelled':
        message = 'Google sign-in was cancelled.';
        break;
      default:
        message = error.message;
        break;
    }
    _showSnack(message, action: action);
  }

  void _showSnack(String message, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
      ),
    );
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'Sign in failed. Please try again.';
    }
  }

  Future<void> _refreshDevDiagnostics() async {
    if (!kDebugMode) return;
    final availability = await GoogleApiAvailability.instance
        .checkGooglePlayServicesAvailability();
    final connectivity = await Connectivity().checkConnectivity();
    final connectivityLabel = connectivity.isEmpty
        ? 'none'
        : connectivity.map((c) => c.name).join('/');

    bool accountAvailable = false;
    try {
      accountAvailable = await GoogleSignIn().isSignedIn();
      if (!accountAvailable) {
        final account = await GoogleSignIn().signInSilently();
        accountAvailable = account != null;
      }
    } catch (_) {}

    setState(() {
      _devDiagnostics =
          'Play Services: $availability • Accounts: ${accountAvailable ? 1 : 0} • Connectivity: $connectivityLabel';
    });
  }

  Future<void> _showGoogleFixSheet() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'How to fix Google sign-in',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('• Ensure the device has Google Play Services and a Google account signed in.'),
                SizedBox(height: 8),
                Text('• Open Play Store once to let Google Play Services update.'),
                SizedBox(height: 8),
                Text('• Retry.'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 120,
                    width: 120,
                    child: FoodiyLogo(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to foodiy',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleEmailSignIn,
                    child: const Text('Sign in'),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.forgotPassword),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: const Icon(Icons.g_translate),
                    label: const Text('Continue with Google'),
                  ),
                  if (kDebugMode && _devDiagnostics != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _devDiagnostics!,
                        style: theme.textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _handleAppleSignIn,
                    icon: const Icon(Icons.apple),
                    label: const Text('Continue with Apple'),
                  ),
                  if (_lastGoogleErrorCode != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showGoogleFixSheet,
                        child: const Text('How to fix'),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      debugPrint('Sign up button pressed');
                      context.go(AppRoutes.signUp);
                    },
                    child: const Text('Do not have an account? Sign up'),
                  ),
                  const SizedBox(height: 12),
                  _LegalFooter(),
                ],
              ),
            ),
          ),
          if (_authController.isLoading)
            const Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: ColoredBox(
                  color: Colors.black26,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

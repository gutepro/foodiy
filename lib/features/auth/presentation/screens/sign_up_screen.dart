import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/shared/widgets/foodiy_logo.dart';
import 'package:foodiy/features/legal/presentation/screens/legal_document_screen.dart';
import 'package:foodiy/features/legal/legal_versions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodiy/core/services/current_user_service.dart';

import '../../auth_dependencies.dart';
import '../../application/auth_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final AuthController _authController;
  bool _agreeToTerms = false;
  bool _showConsentError = false;
  bool _isSubmittingEmail = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _authController = createAuthController()..addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthStateChanged);
    _authController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleGoogleSignUp() async {
    await _handleAuthAction(_authController.signInWithGoogle);
  }

  Future<void> _handleAppleSignUp() async {
    await _handleAuthAction(_authController.signInWithApple);
  }

  Future<void> _handleAuthAction(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();
    try {
      if (!_agreeToTerms) {
        setState(() {
          _showConsentError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please agree to the Terms of Use and Privacy Policy.'),
          ),
        );
        return;
      }

      await action();
      if (!mounted) return;
      await _storeLegalConsent();
      // After signup, go to email verification screen.
      context.go(AppRoutes.verifyEmail);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: ${error.toString()}')),
      );
    }
  }

  Future<void> _handleEmailSignUp() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    if (!_agreeToTerms) {
      setState(() {
        _showConsentError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Use and Privacy Policy.'),
        ),
      );
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email.')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')),
      );
      return;
    }
    if (confirm != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() {
      _isSubmittingEmail = true;
      _showConsentError = false;
    });
    debugPrint('[AUTH_EMAIL_SIGNUP] start email=$email');
    try {
      final credential =
          await _authController.signUpWithEmail(email, password);
      final user = credential.user;
      if (user == null) throw FirebaseAuthException(code: 'user-null');
      debugPrint('[AUTH_EMAIL_SIGNUP] success uid=${user.uid}');
      await _writeUserProfile(user, displayName: user.email ?? email);
      await _storeLegalConsent();
      await _sendVerification(user);
      if (!mounted) return;
      context.go(AppRoutes.verifyEmail);
    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH_EMAIL_SIGNUP] error=${e.code}');
      final message = _mapAuthError(e.code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$message (code: ${e.code})')),
        );
      }
    } catch (e) {
      debugPrint('[AUTH_EMAIL_SIGNUP] error=$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingEmail = false);
      }
    }
  }

  Future<void> _sendVerification(User user) async {
    debugPrint('[EMAIL_VERIFY] send start uid=${user.uid}');
    try {
      await user.sendEmailVerification();
      debugPrint('[EMAIL_VERIFY] send ok uid=${user.uid}');
    } catch (e) {
      debugPrint('[EMAIL_VERIFY] send error uid=${user.uid} error=$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not send verification email. Retry?'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _sendVerification(user),
            ),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _writeUserProfile(User user, {required String displayName}) async {
    debugPrint('[AUTH_PROFILE_WRITE] start uid=${user.uid}');
    final locale = Localizations.localeOf(context).languageCode;
    final data = {
      'displayName': displayName,
      'displayNameLower': displayName.toLowerCase(),
      'email': user.email,
      'userType': 'freeUser',
      'languageCode': locale,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'subscriptionPlanId': '',
      'subscriptionStatus': 'inactive',
      'onboardingComplete': false,
    };
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          data,
          SetOptions(merge: true),
        );
    await CurrentUserService.instance.refreshFromFirebase();
    debugPrint('[AUTH_PROFILE_WRITE] success uid=${user.uid}');
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'That email is already in use. Please sign in instead.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'Sign up failed. Please try again.';
    }
  }

  Future<void> _storeLegalConsent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final data = {
      'legalConsent': {
        'termsAcceptedAt': FieldValue.serverTimestamp(),
        'privacyAcceptedAt': FieldValue.serverTimestamp(),
        'termsVersion': termsVersion,
        'privacyVersion': privacyVersion,
        'locale': locale,
      },
    };
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          data,
          SetOptions(merge: true),
        );
    final prefs = await SharedPreferences.getInstance();
    final nowIso = DateTime.now().toIso8601String();
    await prefs.setString('legal_terms_accepted_version', termsVersion);
    await prefs.setString('legal_privacy_accepted_version', privacyVersion);
    await prefs.setString('legal_accepted_at_iso', nowIso);
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
                    'Create your foodiy account',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join the food discovery community',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(labelText: 'Confirm password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (val) {
                          setState(() {
                            _agreeToTerms = val ?? false;
                            _showConsentError = false;
                          });
                        },
                      ),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('I agree to the '),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LegalDocumentScreen(
                                      title: 'Terms of Use',
                                      assetPath:
                                          'assets/legal/terms_of_use_en.md',
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Terms of Use',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Text(' and '),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LegalDocumentScreen(
                                      title: 'Privacy Policy',
                                      assetPath:
                                          'assets/legal/privacy_policy_en.md',
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Privacy Policy',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_showConsentError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'You must agree to the Terms and Privacy Policy to continue.',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isSubmittingEmail ? null : _handleEmailSignUp,
                    child: _isSubmittingEmail
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign up'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: theme.textTheme.bodySmall),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _handleGoogleSignUp,
                    icon: const Icon(Icons.g_translate),
                    label: const Text('Continue with Google'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _handleAppleSignUp,
                    icon: const Icon(Icons.apple),
                    label: const Text('Continue with Apple'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      debugPrint('Back to login button pressed');
                      context.go(AppRoutes.login);
                    },
                    child: const Text('Already have an account? Sign in'),
                  ),
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

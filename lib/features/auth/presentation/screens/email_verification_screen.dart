import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/router/app_routes.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _sendInitialVerification();
  }

  Future<void> _sendInitialVerification() async {
    final user = _user;
    if (user != null && !user.emailVerified) {
      // TODO: Avoid spamming verification emails; add cooldown.
      await user.sendEmailVerification();
    }
  }

  Future<void> _resend() async {
    final user = _user;
    if (user == null) return;
    await user.sendEmailVerification();
    _showMessage('Verification email sent again.');
  }

  Future<void> _checkVerified() async {
    await _user?.reload();
    final refreshed = FirebaseAuth.instance.currentUser;
    if (refreshed != null && refreshed.emailVerified) {
      context.go(AppRoutes.profileSetup);
    } else {
      _showMessage('Email not verified yet. Please check your inbox.');
    }
  }

  Future<void> _backToLogin() async {
    await FirebaseAuth.instance.signOut();
    context.go(AppRoutes.login);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _user?.email ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We have sent a verification email to your address. Please open the link in your email to verify your account.',
            ),
            const SizedBox(height: 12),
            if (email.isNotEmpty)
              Text(
                'Email: $email',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkVerified,
              child: const Text('I verified my email'),
            ),
            TextButton(
              onPressed: _resend,
              child: const Text('Resend verification email'),
            ),
            TextButton(
              onPressed: _backToLogin,
              child: const Text('Back to login'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/shared/widgets/foodiy_logo.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  User? get _user => FirebaseAuth.instance.currentUser;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

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
    if (_cooldownSeconds > 0) return;
    final user = _user;
    if (user == null) return;
    try {
      await user.sendEmailVerification();
      _startCooldown();
      _showMessage('Verification email sent again.');
    } catch (e) {
      _showMessage('Could not send email. Please try again.');
    }
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

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = 30);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _cooldownSeconds -= 1;
        if (_cooldownSeconds <= 0) {
          _cooldownSeconds = 0;
          _cooldownTimer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
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
      appBar: const FoodiyAppBar(title: Text('Verify your email')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const SizedBox(
              height: 100,
              width: 120,
              child: FoodiyLogo(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Check your email to verify your account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (email.isNotEmpty)
              Text(
                'We sent a verification email to $email.\nTap the link inside to continue.',
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkVerified,
              child: const Text('I verified, continue'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _cooldownSeconds > 0 ? null : _resend,
              child: Text(
                _cooldownSeconds > 0
                    ? 'Resend email ($_cooldownSeconds)'
                    : 'Resend email',
              ),
            ),
            TextButton(
              onPressed: _backToLogin,
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

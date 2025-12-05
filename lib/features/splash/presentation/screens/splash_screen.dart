import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/shared/widgets/foodiy_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 800));
    // We use authStateChanges().first so Firebase has time to restore the persisted user,
    // especially on web where currentUser may be null at startup.
    final user = await FirebaseAuth.instance.authStateChanges().first;
    if (user != null) {
      await CurrentUserService.instance.refreshFromFirebase();
      if (!mounted) return;
      context.go(AppRoutes.home);
    } else {
      if (!mounted) return;
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              height: 120,
              width: 120,
              child: FoodiyLogo(),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(),
          ],
        ),
      ),
      // TODO: Replace delay with real initialization + navigation logic.
    );
  }
}

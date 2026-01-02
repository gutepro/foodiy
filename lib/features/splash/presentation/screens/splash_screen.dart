import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/shared/widgets/foodiy_logo.dart';
import 'package:foodiy/features/legal/application/legal_consent_service.dart';
import 'package:foodiy/features/subscription/presentation/screens/package_selection_screen.dart';

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
      await user.reload();
      await CurrentUserService.instance.refreshFromFirebase();
      final needsConsent =
          await LegalConsentService.instance.shouldPromptConsentFromFirestore();
      final profile = CurrentUserService.instance.currentProfile;
      final tier = (profile?.tierString ?? '').trim();
      final hasTier = tier.isNotEmpty;
      final hasPlanId = (profile?.subscriptionPlanId.isNotEmpty ?? false);
      final onboardingComplete = profile?.onboardingComplete ?? false;
      final needsPlan = !hasTier && !hasPlanId && !onboardingComplete;
      debugPrint(
        '[ROUTER_REDIRECT] loc=splash uid=${user.uid} hasTier=$hasTier hasPlanId=$hasPlanId onboardingComplete=$onboardingComplete verified=${user.emailVerified} -> target=${needsConsent ? AppRoutes.legalConsent : !user.emailVerified ? AppRoutes.verifyEmail : needsPlan ? AppRoutes.selectPackage : AppRoutes.home}',
      );
      if (!mounted) return;
      if (needsConsent) {
        context.go(AppRoutes.legalConsent);
      } else if (!user.emailVerified) {
        context.go(AppRoutes.verifyEmail);
      } else if (needsPlan) {
        context.go(
          AppRoutes.selectPackage,
          extra: PlanPickerEntrySource.onboarding,
        );
      } else {
        context.go(AppRoutes.home);
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final seenOnboarding = prefs.getBool('has_seen_onboarding_v1') ?? false;
      if (!mounted) return;
      if (seenOnboarding) {
        context.go(AppRoutes.login);
      } else {
        context.go(AppRoutes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DEBUG MAIN: SplashScreen.build() called');
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                height: 180,
                width: 240,
                child: FoodiyLogo(),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
      // TODO: Replace delay with real initialization + navigation logic.
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/router/app_routes.dart';

bool get isGuestUser => FirebaseAuth.instance.currentUser?.isAnonymous == true;

Future<bool> ensureNotGuest(BuildContext context) async {
  if (!isGuestUser) return true;
  if (!context.mounted) return false;
  final shouldSignIn = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sign in required'),
          content: const Text('Sign in to use this feature. Browsing is available as guest.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ) ??
      false;
  if (shouldSignIn && context.mounted) {
    context.go(AppRoutes.login);
  }
  return false;
}

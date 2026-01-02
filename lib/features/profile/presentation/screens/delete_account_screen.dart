import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:foodiy/core/services/session_service.dart';
import 'package:foodiy/features/playlist/application/playlist_firestore_service.dart';
import 'package:foodiy/router/app_routes.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isDeleting = false;
  bool _requiresPassword = false;
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final providers = FirebaseAuth.instance.currentUser?.providerData ?? const [];
    _requiresPassword = providers.any((p) => p.providerId == 'password');
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onDeleteAccountPressed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No logged in user')));
      return;
    }

    final confirmed = await _confirmDeletion();
    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await _reauthenticate(user);
      await _deleteUserData(user.uid);
      await user.delete();
      await SessionService.instance.signOut();
      if (!mounted) return;
      context.go(AppRoutes.login);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted')),
      );
    } catch (e, st) {
      debugPrint('Delete account failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete account: ${_errorLabel(e)}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<bool?> _confirmDeletion() {
    bool acknowledged = false;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Delete account?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This will permanently delete your account and data.',
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: acknowledged,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    setState(() {
                      acknowledged = value ?? false;
                    });
                  },
                  title: const Text('I understand the consequences.'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: acknowledged
                    ? () => Navigator.of(dialogContext).pop(true)
                    : null,
                child: const Text('Delete account'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _reauthenticate(User user) async {
    final providers = user.providerData.map((p) => p.providerId).toList();
    final providerId = _resolveProvider(providers);
    switch (providerId) {
      case 'google.com':
        await _reauthenticateWithGoogle(user);
        return;
      case 'apple.com':
        await _reauthenticateWithApple(user);
        return;
      case 'password':
        await _reauthenticateWithPassword(user);
        return;
      default:
        throw FirebaseAuthException(
          code: 'unsupported-provider',
          message: 'Unsupported auth provider for account deletion.',
        );
    }
  }

  String _resolveProvider(List<String> providers) {
    if (providers.contains('google.com')) return 'google.com';
    if (providers.contains('apple.com')) return 'apple.com';
    if (providers.contains('password')) return 'password';
    return providers.isNotEmpty ? providers.first : '';
  }

  GoogleSignIn _googleSignIn() {
    return kIsWeb
        ? GoogleSignIn(
            clientId:
                '988257088468-atmtio8368tq3u9aptftbqiaebppek32.apps.googleusercontent.com',
          )
        : GoogleSignIn();
  }

  Future<void> _reauthenticateWithGoogle(User user) async {
    final googleUser = await _googleSignIn().signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Google sign-in was cancelled.',
      );
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> _reauthenticateWithApple(User user) async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    await user.reauthenticateWithCredential(oauthCredential);
  }

  Future<void> _reauthenticateWithPassword(User user) async {
    final email = user.email;
    final password = _passwordController.text.trim();
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'email-missing',
        message: 'Email not available for the current user.',
      );
    }
    if (password.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-password',
        message: 'Please enter your password to continue.',
      );
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> _deleteUserData(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final recipesSnap = await firestore
        .collection('recipes')
        .where('chefId', isEqualTo: uid)
        .get();
    final recipeIds = recipesSnap.docs.map((doc) => doc.id).toList();
    await _deleteDocs(recipesSnap.docs);

    for (final recipeId in recipeIds) {
      await PlaylistFirestoreService.instance
          .removeRecipeFromAllCookbooks(recipeId);
    }

    final cookbooksSnap = await firestore
        .collection('cookbooks')
        .where('ownerId', isEqualTo: uid)
        .get();
    for (final cookbook in cookbooksSnap.docs) {
      final entries = await cookbook.reference.collection('entries').get();
      await _deleteDocs(entries.docs);
      await cookbook.reference.delete();
    }

    final userPlaylistsSnap = await firestore
        .collection('users')
        .doc(uid)
        .collection('playlists')
        .get();
    for (final playlist in userPlaylistsSnap.docs) {
      final entries = await playlist.reference.collection('entries').get();
      await _deleteDocs(entries.docs);
      await playlist.reference.delete();
    }

    await firestore.collection('users').doc(uid).delete();
  }

  Future<void> _deleteDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    if (docs.isEmpty) return;
    final firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    var count = 0;
    for (final doc in docs) {
      batch.delete(doc.reference);
      count++;
      if (count >= 400) {
        await batch.commit();
        batch = firestore.batch();
        count = 0;
      }
    }
    if (count > 0) {
      await batch.commit();
    }
  }

  String _errorLabel(Object error) {
    if (error is FirebaseAuthException) {
      return error.message ?? error.code;
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete your account',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'This will permanently delete your Foodiy account.\n'
              'You will lose access to your recipes, playlists and activity.\n\n'
              'This action cannot be undone.',
            ),
            if (_requiresPassword) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                ),
                obscureText: true,
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _isDeleting ? null : _onDeleteAccountPressed,
                child: _isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Delete my account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

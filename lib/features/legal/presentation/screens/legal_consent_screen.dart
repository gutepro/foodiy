import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodiy/features/legal/legal_versions.dart';
import 'package:foodiy/features/legal/presentation/screens/legal_document_screen.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class LegalConsentScreen extends StatefulWidget {
  const LegalConsentScreen({super.key});

  @override
  State<LegalConsentScreen> createState() => _LegalConsentScreenState();
}

class _LegalConsentScreenState extends State<LegalConsentScreen> {
  bool _agreed = false;
  bool _saving = false;

  Future<void> _accept() async {
    if (_saving) return;
    setState(() {
      _saving = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        context.go(AppRoutes.login);
        return;
      }
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
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save consent: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Legal consent required')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please review and accept our Terms of Use and Privacy Policy.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
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
              child: const Text('View Terms of Use'),
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
              child: const Text('View Privacy Policy'),
            ),
            Row(
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (val) {
                    setState(() {
                      _agreed = val ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'I agree to the Terms of Use and Privacy Policy.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agreed && !_saving ? _accept : null,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

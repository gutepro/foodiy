import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodiy/features/legal/legal_versions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LegalConsentService {
  LegalConsentService._internal();
  static final LegalConsentService instance = LegalConsentService._internal();

  Future<bool> isConsentUpToDate() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTerms = prefs.getString('legal_terms_accepted_version');
    final storedPrivacy = prefs.getString('legal_privacy_accepted_version');
    return storedTerms == termsVersion && storedPrivacy == privacyVersion;
  }

  Future<bool> shouldPromptConsentFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return true;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data == null) return true;
    final consent = data['legalConsent'] as Map<String, dynamic>?;
    if (consent == null) return true;
    final termsAccepted = consent['termsAcceptedAt'];
    final privacyAccepted = consent['privacyAcceptedAt'];
    final termsVer = consent['termsVersion'] as String?;
    final privacyVer = consent['privacyVersion'] as String?;
    if (termsAccepted == null || privacyAccepted == null) return true;
    if (termsVer != termsVersion || privacyVer != privacyVersion) return true;
    return false;
  }
}

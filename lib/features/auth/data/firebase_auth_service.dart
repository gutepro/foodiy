import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../domain/auth_service.dart';

class GoogleSignInFailure implements Exception {
  GoogleSignInFailure({
    required this.code,
    required this.message,
    this.stackTrace,
  });

  final String code;
  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() => 'GoogleSignInFailure($code): $message';
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            (kIsWeb
                ? GoogleSignIn(
                    clientId:
                        '988257088468-atmtio8368tq3u9aptftbqiaebppek32.apps.googleusercontent.com',
                  )
                : GoogleSignIn());

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Future<void> signInWithGoogle() async {
    await _ensureAndroidPreconditions();

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw GoogleSignInFailure(
          code: 'cancelled',
          message: 'Google sign in aborted.',
        );
      }

      final googleAuth = await googleUser.authentication;
      final isAndroid =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
      if (isAndroid) {
        debugPrint(
          'GoogleSignIn[android] tokens received: idToken=${googleAuth.idToken != null}, accessToken=${googleAuth.accessToken != null}',
        );
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } on PlatformException catch (error, stackTrace) {
      debugPrint('GoogleSignIn PlatformException: $error\n$stackTrace');
      final message = error.toString();
      if (message.contains('ApiException: 7')) {
        throw GoogleSignInFailure(
          code: 'api_exception_7',
          message:
              'Google sign-in failed. Please update Google Play services and try again.',
          stackTrace: stackTrace,
        );
      }
      throw GoogleSignInFailure(
        code: 'platform_exception',
        message: 'Google sign-in failed. ${error.message ?? 'Please try again.'}',
        stackTrace: stackTrace,
      );
    } on GoogleSignInFailure {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('GoogleSignIn unexpected error: $error\n$stackTrace');
      throw GoogleSignInFailure(
        code: 'unknown',
        message: 'Google sign-in failed. Please try again.',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> signInWithApple() async {
    // TODO: Configure Apple Sign In service identifiers for iOS and macOS.
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

    await _firebaseAuth.signInWithCredential(oauthCredential);
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  Future<_AndroidSignInDiagnostics?> _ensureAndroidPreconditions() async {
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (!isAndroid) return null;

    final diagnostics = await _collectAndroidDiagnostics();

    debugPrint(
      'GoogleSignIn[android] device=${diagnostics.model} sdk=${diagnostics.sdkInt} '
      'emulator=${diagnostics.isEmulator} playServices=${diagnostics.playServicesStatus} '
      'connectivity=${diagnostics.connectivity} hasNetwork=${diagnostics.hasNetwork} '
      'hasGoogleAccount=${diagnostics.hasGoogleAccount} accountCheckError=${diagnostics.accountCheckError ?? 'none'}',
    );

    if (!diagnostics.hasNetwork) {
      throw GoogleSignInFailure(
        code: 'no_network',
        message: 'No internet connection. Please try again.',
      );
    }

    if (diagnostics.playServicesAvailability !=
        GooglePlayServicesAvailability.success) {
      if (diagnostics.playServicesAvailability ==
          GooglePlayServicesAvailability.serviceUpdating) {
        throw GoogleSignInFailure(
          code: 'play_services_updating',
          message: 'Google Play Services is updating. Try again shortly.',
        );
      }
      if (diagnostics.playServicesAvailability ==
          GooglePlayServicesAvailability.serviceMissing) {
        throw GoogleSignInFailure(
          code: 'play_services_missing',
          message:
              'Google Play Services required. Use a Google Play emulator or a real device.',
        );
      }
      throw GoogleSignInFailure(
        code: 'play_services_unavailable',
        message:
            'Google Play Services unavailable. Status: ${diagnostics.playServicesStatus}',
      );
    }

    return diagnostics;
  }

  Future<_AndroidSignInDiagnostics> _collectAndroidDiagnostics() async {
    final deviceInfo = DeviceInfoPlugin();
    String? model;
    int? sdkInt;
    bool? isEmulator;
    try {
      final android = await deviceInfo.androidInfo;
      model = android.model;
      sdkInt = android.version.sdkInt;
      isEmulator = !android.isPhysicalDevice;
    } catch (error, stackTrace) {
      debugPrint('GoogleSignIn[android] device info error: $error\n$stackTrace');
    }

    final connectivity = await Connectivity().checkConnectivity();
    final hasNetwork = connectivity
        .where((result) => result != ConnectivityResult.none)
        .isNotEmpty;

    final playServicesAvailability = await GoogleApiAvailability.instance
        .checkGooglePlayServicesAvailability();
    String playServicesStatus = playServicesAvailability.toString();

    bool hasGoogleAccount = false;
    String? accountCheckError;
    try {
      hasGoogleAccount = await _googleSignIn.isSignedIn();
      if (!hasGoogleAccount) {
        final silentAccount = await _googleSignIn.signInSilently();
        hasGoogleAccount = silentAccount != null;
      }
    } catch (error, stackTrace) {
      accountCheckError = error.toString();
      debugPrint('GoogleSignIn[android] account check error: $error\n$stackTrace');
    }

    return _AndroidSignInDiagnostics(
      model: model ?? 'unknown',
      sdkInt: sdkInt ?? -1,
      isEmulator: isEmulator ?? false,
      playServicesAvailability: playServicesAvailability,
      playServicesStatus: playServicesStatus,
      connectivity: connectivity,
      hasNetwork: hasNetwork,
      hasGoogleAccount: hasGoogleAccount,
      accountCheckError: accountCheckError,
    );
  }
}

class _AndroidSignInDiagnostics {
  _AndroidSignInDiagnostics({
    required this.model,
    required this.sdkInt,
    required this.isEmulator,
    required this.playServicesAvailability,
    required this.playServicesStatus,
    required this.connectivity,
    required this.hasNetwork,
    required this.hasGoogleAccount,
    required this.accountCheckError,
  });

  final String model;
  final int sdkInt;
  final bool isEmulator;
  final GooglePlayServicesAvailability playServicesAvailability;
  final String playServicesStatus;
  final List<ConnectivityResult> connectivity;
  final bool hasNetwork;
  final bool hasGoogleAccount;
  final String? accountCheckError;
}

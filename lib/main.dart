import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'router.dart';
import 'package:foodiy/features/analytics/application/recipe_analytics_service.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/playlist/application/public_chef_playlist_service.dart';
import 'package:foodiy/shared/services/ads_service.dart';
import 'package:foodiy/core/services/subscription_service.dart';
import 'package:foodiy/features/settings/application/settings_service.dart';

typedef MyApp = FoodiyRouter;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    final exception = details.exception;
    final stack = details.stack ?? StackTrace.current;
    debugPrint('GLOBAL ErrorWidget exception: $exception');
    debugPrint(_shortStack(stack));
    return const Material(
      child: Center(
        child: Text(
          'Something went wrong.\nPlease go back.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    final stack = details.stack ?? StackTrace.current;
    debugPrint('GLOBAL FlutterError: ${details.exceptionAsString()}');
    debugPrint(_shortStack(stack));
  };

  runZonedGuarded(() async {
    debugPrint('DEBUG MAIN: main() starting (zoned)');

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        debugPrint(
          'FIREBASE INIT: default app already exists, using existing app.',
        );
      }
    } on FirebaseException catch (e, st) {
      if (e.code == 'duplicate-app') {
        debugPrint(
          'FIREBASE INIT: duplicate-app, using existing default app.\n$e\n$st',
        );
      } else {
        debugPrint('FIREBASE INIT ERROR: $e\n$st');
        rethrow;
      }
    }

    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }

    await PersonalPlaylistService.instance.loadFromStorage();
    await RecipeAnalyticsService.instance.loadFromStorage();
    await PublicChefPlaylistService.instance.loadFromFirestore();
    await SubscriptionService.instance.start();
    await AdsService.init();
    await SettingsService.instance.loadFromStorage();
    final options = Firebase.app().options;
    final platform = Platform.operatingSystem;
    debugPrint(
      '[FIREBASE_ENV] platform=$platform projectId=${options.projectId} bucket=${options.storageBucket} appId=${options.appId}',
    );
    runApp(const FoodiyRouter());
  }, (error, stack) {
    debugPrint('GLOBAL Zone error: $error');
    debugPrint(_shortStack(stack));
  });
}

String _shortStack(StackTrace stack) {
  final lines = stack.toString().split('\n');
  final libLines = lines.where((l) => l.contains('/lib/')).toList();
  final picked = libLines.isNotEmpty ? libLines.take(25) : lines.take(25);
  return picked.join('\n');
}

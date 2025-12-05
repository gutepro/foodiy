import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'router.dart';
import 'package:foodiy/features/analytics/application/recipe_analytics_service.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/playlist/application/public_chef_playlist_service.dart';

typedef MyApp = FoodiyRouter;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kIsWeb) {
    // TODO: Consider exposing persistence setting to platform-specific configuration.
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  await PersonalPlaylistService.instance.loadFromStorage();
  await RecipeAnalyticsService.instance.loadFromStorage();
  await PublicChefPlaylistService.instance.loadFromFirestore();
  // TODO: Refresh CurrentUserService.fromFirebase() once auth state is ready.
  runApp(const FoodiyRouter());
}

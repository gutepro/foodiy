import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/chefs/chef_screen.dart';
import 'features/discovery/discovery_screen.dart';
import 'features/playlists/playlists_screen.dart';
import 'features/recipes/recipe_screen.dart';
import 'features/shopping_list/shopping_list_screen.dart';

/// Shared GoRouter configuration for the Foodiy app.
final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const DiscoveryScreen(),
    ),
    GoRoute(
      path: '/recipe',
      builder: (context, state) => const RecipeScreen(),
    ),
    GoRoute(
      path: '/chef',
      builder: (context, state) => const ChefScreen(),
    ),
    GoRoute(
      path: '/playlists',
      builder: (context, state) => const PlaylistsScreen(),
    ),
    GoRoute(
      path: '/shopping',
      builder: (context, state) => const ShoppingListScreen(),
    ),
  ],
);

/// Wraps [MaterialApp.router] with the shared GoRouter config.
class FoodiyRouter extends StatelessWidget {
  const FoodiyRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'foodiy',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
    );
  }
}

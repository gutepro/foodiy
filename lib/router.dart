import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/chefs/chef_screen.dart';
import 'features/discovery/discovery_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/playlists/playlists_screen.dart';
import 'features/recipe/presentation/screens/recipe_details_screen.dart';
import 'features/recipe/presentation/screens/recipe_player_screen.dart';
import 'features/recipe/presentation/screens/recipe_upload_screen.dart';
import 'features/recipes/recipe_screen.dart';
import 'features/playlist/presentation/screens/playlist_details_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/email_verification_screen.dart';
import 'features/auth/presentation/screens/initial_profile_setup_screen.dart';
import 'features/search/presentation/screens/search_screen.dart';
import 'features/search/presentation/screens/search_results_screen.dart';
import 'features/shell/presentation/screens/main_shell_screen.dart';
import 'features/shopping_list/shopping_list_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'router/app_routes.dart';
import 'shared/theme/theme.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.verifyEmail,
      builder: (context, state) => const EmailVerificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.profileSetup,
      builder: (context, state) => const InitialProfileSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.searchResults,
      builder: (context, state) {
        final args = state.extra as SearchResultsArgs?;
        return SearchResultsScreen(
          args: args ??
              const SearchResultsArgs(
                query: '',
              ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainShellScreen(),
    ),
    GoRoute(
      path: AppRoutes.discovery,
      builder: (context, state) => const DiscoveryScreen(),
    ),
    GoRoute(
      path: AppRoutes.recipe,
      builder: (context, state) => const RecipeScreen(),
    ),
    GoRoute(
      path: AppRoutes.recipeDetails,
      builder: (context, state) {
        final args = state.extra as RecipeDetailsArgs?;
        return RecipeDetailsScreen(
          args: args ??
              const RecipeDetailsArgs(
                title: 'Recipe',
                imageUrl: 'https://via.placeholder.com/900x600',
                time: '-',
                difficulty: '-',
              ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.recipePlayer,
      builder: (context, state) {
        final args = state.extra as RecipePlayerArgs?;
        return RecipePlayerScreen(
          args: args ??
              const RecipePlayerArgs(
                title: 'Recipe player',
                imageUrl: 'https://via.placeholder.com/900x600',
                steps: [],
              ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.recipeCreate,
      builder: (context, state) => const RecipeUploadScreen(),
    ),
    GoRoute(
      path: AppRoutes.playlistDetails,
      builder: (context, state) {
        final args = state.extra as PlaylistDetailsArgs?;
        return PlaylistDetailsScreen(
          args: args ??
              const PlaylistDetailsArgs(
                title: 'Playlist',
                imageUrl: 'https://via.placeholder.com/900x600',
                description: 'Mock playlist',
                totalTime: '30 min',
                recipes: [],
              ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.chef,
      builder: (context, state) => const ChefScreen(),
    ),
    GoRoute(
      path: AppRoutes.playlists,
      builder: (context, state) => const PlaylistsScreen(),
    ),
    GoRoute(
      path: AppRoutes.shopping,
      builder: (context, state) => const ShoppingListScreen(),
    ),
  ],
);

class FoodiyRouter extends StatelessWidget {
  const FoodiyRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'foodiy',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: FoodiyTheme.light,
      supportedLocales: const [
        Locale('he'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
        }
        return const Locale('he');
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const FoodiyRouter();
  }
}

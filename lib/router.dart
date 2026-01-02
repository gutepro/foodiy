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
import 'features/recipe/presentation/screens/recipe_import_document_screen.dart';
import 'features/recipe/presentation/screens/import_needs_review_screen.dart';
import 'features/recipe/presentation/screens/import_failed_screen.dart';
import 'features/recipe/domain/recipe.dart';
import 'features/recipe/application/recipe_firestore_service.dart';
import 'features/playlist/presentation/screens/playlist_details_screen.dart';
import 'features/playlist/presentation/screens/my_playlists_screen.dart';
import 'features/playlist/presentation/screens/personal_playlist_details_screen.dart';
import 'features/playlist/presentation/screens/public_chef_playlist_details_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/email_verification_screen.dart';
import 'features/auth/presentation/screens/initial_profile_setup_screen.dart';
import 'features/profile/presentation/screens/user_activity_screen.dart';
import 'features/search/presentation/screens/search_screen.dart';
import 'features/search/presentation/screens/search_results_screen.dart';
import 'features/shell/presentation/screens/main_shell_screen.dart';
import 'features/shopping/presentation/screens/shopping_history_screen.dart';
import 'features/shopping/presentation/screens/shopping_history_details_screen.dart';
import 'features/shopping/presentation/screens/shopping_list_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/legal/presentation/screens/legal_consent_screen.dart';
import 'features/subscription/presentation/screens/package_selection_screen.dart';
import 'features/subscription/presentation/screens/subscription_checkout_placeholder_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/chef/presentation/screens/chef_profile_screen.dart';
import 'features/chef/presentation/screens/edit_chef_profile_screen.dart';
import 'router/app_routes.dart';
import 'shared/theme/theme.dart';
import 'features/settings/application/settings_service.dart';
import 'package:foodiy/l10n/app_localizations.dart';

const _supportedAppLocales = [
  Locale('en'),
  Locale('he'),
  Locale('es'),
  Locale('fr'),
  Locale('ar'),
  Locale('zh'),
  Locale('ja'),
  Locale('it'),
];

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
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
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
          args: args ?? const SearchResultsArgs(query: ''),
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
      path: AppRoutes.recipeDetails,
      builder: (context, state) {
        final args = state.extra as RecipeDetailsArgs?;
        return RecipeDetailsScreen(
          args:
              args ??
              const RecipeDetailsArgs(
                title: 'Recipe',
                imageUrl: '',
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
          args:
              args ??
              const RecipePlayerArgs(
                title: 'Recipe player',
                imageUrl: '',
                steps: [],
              ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.recipeCreate,
      builder: (context, state) {
        final recipe = state.extra as Recipe?;
        return RecipeUploadScreen(recipe: recipe);
      },
    ),
    GoRoute(
      path: AppRoutes.recipeEdit,
      builder: (context, state) {
        final id = state.extra as String?;
        if (id == null || id.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Recipe not found')),
          );
        }
        return FutureBuilder<Recipe?>(
          future: RecipeFirestoreService.instance.getRecipeById(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final recipe = snapshot.data;
            if (recipe == null) {
              return const Scaffold(
                body: Center(child: Text('Recipe not found')),
              );
            }
            return RecipeUploadScreen(recipe: recipe);
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.recipeImportDocument,
      builder: (context, state) => const RecipeImportDocumentScreen(),
    ),
    GoRoute(
      path: AppRoutes.recipeImportNeedsReview,
      builder: (context, state) {
        final recipe = state.extra as Recipe?;
        return ImportNeedsReviewScreen(recipe: recipe);
      },
    ),
    GoRoute(
      path: AppRoutes.playlistDetails,
      builder: (context, state) {
        final args = state.extra as PlaylistDetailsArgs?;
        return PlaylistDetailsScreen(
          args:
              args ??
              const PlaylistDetailsArgs(
                title: 'Playlist',
                imageUrl: '',
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
      path: AppRoutes.shoppingList,
      builder: (context, state) => const ShoppingListScreen(),
    ),
    GoRoute(
      path: AppRoutes.shoppingHistory,
      builder: (context, state) => const ShoppingHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.shoppingHistoryDetails,
      builder: (context, state) {
        final args = state.extra as ShoppingHistoryDetailsArgs;
        return ShoppingHistoryDetailsScreen(args: args);
      },
    ),
    GoRoute(
      path: AppRoutes.selectPackage,
      builder: (context, state) => PackageSelectionScreen(
        source: (state.extra as PlanPickerEntrySource?) ??
            PlanPickerEntrySource.settings,
      ),
    ),
    GoRoute(
      path: AppRoutes.subscriptionCheckout,
      builder: (context, state) =>
          const SubscriptionCheckoutPlaceholderScreen(),
    ),
    GoRoute(
      path: AppRoutes.myPlaylists,
      builder: (context, state) => const MyPlaylistsScreen(),
    ),
    GoRoute(
      path: AppRoutes.myPlaylistsDetails,
      builder: (context, state) {
        final args =
            state.extra as PersonalPlaylistDetailsArgs? ??
            const PersonalPlaylistDetailsArgs(playlistId: '');
        return PersonalPlaylistDetailsScreen(args: args);
      },
    ),
    GoRoute(
      path: AppRoutes.publicChefPlaylist,
      builder: (context, state) {
        final args = state.extra as PublicChefPlaylistDetailsArgs;
        return PublicChefPlaylistDetailsScreen(args: args);
      },
    ),
    GoRoute(
      path: AppRoutes.userActivity,
      builder: (context, state) => const UserActivityScreen(),
    ),
    GoRoute(
      path: AppRoutes.chefProfile,
      builder: (context, state) {
        final chefId = state.extra as String?;
        if (chefId == null || chefId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Chef not found')),
          );
        }
        return ChefProfileScreen(chefId: chefId);
      },
    ),
    GoRoute(
      path: AppRoutes.editChefProfile,
      builder: (context, state) {
        final chefId = state.extra as String?;
        if (chefId == null || chefId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Chef not found')),
          );
        }
        return EditChefProfileScreen(chefId: chefId);
      },
    ),
    GoRoute(
      path: AppRoutes.legalConsent,
      builder: (context, state) => const LegalConsentScreen(),
    ),
  ],
);

class FoodiyRouter extends StatelessWidget {
  const FoodiyRouter({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('DEBUG MAIN: FoodiyRouter.build() called');
    final settings = SettingsService.instance;

    return ValueListenableBuilder<String?>(
      valueListenable: settings.localeListenable,
      builder: (context, localeCode, _) {
        final locale = settings.resolvedLocale;
        debugPrint(
          '[APP_LOCALE] locale=${locale?.toLanguageTag() ?? 'system'}',
        );
        return MaterialApp.router(
          title: 'foodiy',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: FoodiyTheme.light,
          supportedLocales: _supportedAppLocales,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            if (locale != null) return locale;
            if (deviceLocale != null) {
              for (final supported in supportedLocales) {
                if (supported.languageCode == deviceLocale.languageCode) {
                  return supported;
                }
              }
            }
            // Default to English so unknown locales do not flip punctuation or
            // text direction unexpectedly.
            return const Locale('en');
          },
        );
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

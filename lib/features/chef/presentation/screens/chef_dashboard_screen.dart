import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/access_control_service.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/analytics/application/recipe_analytics_service.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/recipe/application/recipe_firestore_service.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';
import 'package:foodiy/router/app_routes.dart';

class ChefDashboardScreen extends StatelessWidget {
  const ChefDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final profile = CurrentUserService.instance.currentProfile;
    final userType = profile?.userType ?? UserType.freeUser;
    final access = AccessControlService.instance;
    final isPremiumChef = userType == UserType.premiumChef;

    if (!isPremiumChef) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chef dashboard')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'The chef dashboard is available only for Premium chef accounts.\n\n'
              'Upgrade to a premium chef plan to access advanced stats and tools.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final uid = user?.uid ?? '';
    final playlistService = PersonalPlaylistService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Chef dashboard')),
      body: StreamBuilder<List<Recipe>>(
        stream: RecipeFirestoreService.instance.watchUserRecipes(uid: uid),
        builder: (context, snapshot) {
          final recipes = snapshot.data ?? const <Recipe>[];
          final filtered =
              uid.isEmpty ? recipes : recipes.where((r) => r.chefId == uid).toList();
          final totalRecipes = filtered.length;
          final recipeIds = filtered.map((r) => r.id);
          final analytics = RecipeAnalyticsService.instance;
          final totalViews = analytics.getTotalViewsForRecipes(recipeIds);
          final cookbooks = playlistService.getCurrentUserPlaylists();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user != null) ...[
                  Text(
                    user.displayName ?? (user.email ?? 'Chef'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Premium chef',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatCard(
                      label: 'My recipes',
                      value: '$totalRecipes',
                      icon: Icons.restaurant_menu,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _ChefRecipesListScreen(recipes: filtered),
                        ),
                      ),
                    ),
                    _StatCard(
                      label: 'My cookbooks',
                      value: '${cookbooks.length}',
                      icon: Icons.menu_book,
                      onTap: () => context.push(AppRoutes.myPlaylists),
                    ),
                    _StatCard(
                      label: 'Total views',
                      value: '$totalViews',
                      icon: Icons.visibility,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('My recipes', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (filtered.isEmpty)
                  const Text('No recipes yet.')
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length > 3 ? 3 : filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final recipe = filtered[index];
                      return ListTile(
                        leading: const Icon(Icons.restaurant_menu),
                        title: Text(recipe.title),
                        subtitle: Text('${recipe.steps.length} steps'),
                        onTap: () {
                          final localeCode =
                              Localizations.localeOf(context).languageCode;
                          context.push(
                            AppRoutes.recipeDetails,
                            extra: RecipeDetailsArgs(
                              id: recipe.id,
                              title: recipe.title,
                              imageUrl: recipe.imageUrl,
                              time: '${recipe.steps.length} steps',
                              difficulty: '-',
                              originalLanguageCode: localeCode,
                              ingredients: recipe.ingredients,
                              steps: recipe.steps,
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 160,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 24),
                const SizedBox(height: 8),
                Text(value, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(label, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChefRecipesListScreen extends StatelessWidget {
  const _ChefRecipesListScreen({required this.recipes});

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: const Text('My recipes')),
      body: recipes.isEmpty
          ? const Center(child: Text('No recipes yet.'))
          : ListView.separated(
              itemCount: recipes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return ListTile(
                  leading: const Icon(Icons.restaurant_menu),
                  title: Text(recipe.title),
                  subtitle: Text('${recipe.steps.length} steps'),
                  onTap: () {
                    context.push(
                      AppRoutes.recipeDetails,
                      extra: RecipeDetailsArgs(
                        id: recipe.id,
                        title: recipe.title,
                        imageUrl: recipe.imageUrl,
                        time: '${recipe.steps.length} steps',
                        difficulty: '-',
                        originalLanguageCode: localeCode,
                        ingredients: recipe.ingredients,
                        steps: recipe.steps,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

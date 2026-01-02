import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodiy/core/brand/brand_assets.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/analytics/application/recipe_analytics_service.dart';
import 'package:foodiy/features/chef/application/chef_recipes_service.dart';
import 'package:foodiy/features/recipe/application/recipe_firestore_service.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';
import 'package:foodiy/router/app_routes.dart';

class ChefMyRecipesScreen extends StatefulWidget {
  const ChefMyRecipesScreen({super.key});

  @override
  State<ChefMyRecipesScreen> createState() => _ChefMyRecipesScreenState();
}

class _ChefMyRecipesScreenState extends State<ChefMyRecipesScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final localeCode = Localizations.localeOf(context).languageCode;
    final analytics = RecipeAnalyticsService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My recipes'),
        leading: const BackButton(),
      ),
      body: uid.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('You have not published any recipes yet'),
              ),
            )
          : StreamBuilder<List<Recipe>>(
              stream:
                  RecipeFirestoreService.instance.watchUserRecipes(uid: uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Failed to load recipes. Please try again.'),
                  );
                }
                final recipes = snapshot.data ?? const <Recipe>[];
                if (recipes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('You have not published any recipes yet'),
                    ),
                  );
                }
                final summaries = recipes
                    .map(
                      (r) => ChefRecipeSummary(
                        id: r.id,
                        title: r.title,
                        imageUrl:
                            (r.coverImageUrl != null && r.coverImageUrl!.isNotEmpty)
                                ? r.coverImageUrl
                                : r.imageUrl,
                        time: '${r.steps.length} steps',
                        difficulty: '-',
                        chefId: r.chefId,
                        chefName: r.chefName,
                        chefAvatarUrl: r.chefAvatarUrl,
                        views: r.views,
                        playlistAdds: r.playlistAdds,
                        isPublic: r.isPublic,
                      ),
                    )
                    .toList();
                return ListView.builder(
                  itemCount: summaries.length,
                  itemBuilder: (context, index) {
                    final summary = summaries[index];
                    final views = analytics.getTotalViewsForRecipes(<String>[
                      summary.id,
                    ]);
                    final adds = analytics.getTotalPlaylistAddsForRecipes(
                      <String>[summary.id],
                    );
                    return ListTile(
                      leading: SizedBox(
                        width: 56,
                        height: 56,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildRecipeImage(summary),
                        ),
                      ),
                      title: Text(summary.title),
                      subtitle: Text(
                        '${summary.time}\nViews: $views • Saves: $adds',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              context.push(
                                AppRoutes.recipeEdit,
                                extra: summary.id,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete recipe',
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: const Text('Delete recipe'),
                                    content: Text(
                                      'Are you sure you want to delete "${summary.title}"? This cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmed != true) {
                                return;
                              }

                              try {
                                debugPrint(
                                  'ChefMyRecipes: deleting recipe id=${summary.id}, title=${summary.title}',
                                );
                                await RecipeFirestoreService.instance.deleteRecipe(summary.id);
                                ChefRecipesService.instance.removeRecipe(summary.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Recipe "${summary.title}" deleted'),
                                    ),
                                  );
                                }
                              } catch (e, st) {
                                debugPrint(
                                  'ChefMyRecipes: failed to delete recipe ${summary.id}: $e\n$st',
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to delete recipe: $e'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        context.push(
                          AppRoutes.recipeDetails,
                        extra: RecipeDetailsArgs(
                          id: summary.id,
                          title: summary.title,
                          imageUrl:
                              summary.imageUrl ?? '',
                          time: summary.time,
                          difficulty: '-',
                          originalLanguageCode: localeCode,
                          ingredients: recipes[index].ingredients,
                          steps: recipes[index].steps,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildRecipeImage(ChefRecipeSummary summary) {
    final url = summary.imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) {
          return _placeholderImage();
        },
      );
    }
    return _placeholderImage();
  }

  Widget _placeholderImage() {
    return Image.asset(
      BrandAssets.foodiyLogo,
      fit: BoxFit.contain,
    );
  }
}

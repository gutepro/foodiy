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
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class ChefMyRecipesScreen extends StatefulWidget {
  const ChefMyRecipesScreen({super.key});

  @override
  State<ChefMyRecipesScreen> createState() => _ChefMyRecipesScreenState();
}

class _ChefMyRecipesScreenState extends State<ChefMyRecipesScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    debugPrint(
      '[L10N] locale=${Localizations.localeOf(context)} screen=chef_my_recipes',
    );
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final localeCode = Localizations.localeOf(context).languageCode;
    final analytics = RecipeAnalyticsService.instance;

    return Scaffold(
      appBar: FoodiyAppBar(title: Text(l10n.myRecipesTitle)),
      body: uid.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(l10n.chefNoRecipesYet),
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
                  return Center(
                    child: Text(l10n.chefLoadRecipesFailed),
                  );
                }
                final recipes = snapshot.data ?? const <Recipe>[];
                if (recipes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(l10n.chefNoRecipesYet),
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
                        time: l10n.profileStepsCount(r.steps.length),
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
                        '${summary.time}\n${l10n.chefRecipeStats(views, adds)}',
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
                            tooltip: l10n.homeDeleteRecipeTitle,
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: Text(l10n.homeDeleteRecipeTitle),
                                    content: Text(
                                      l10n.homeDeleteRecipeMessage(
                                        summary.title,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: Text(l10n.homeCancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: Text(l10n.homeDelete),
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
                                      content: Text(
                                        l10n.chefRecipeDeleted(summary.title),
                                      ),
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
                                      content:
                                          Text(l10n.homeDeleteRecipeFailed('$e')),
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

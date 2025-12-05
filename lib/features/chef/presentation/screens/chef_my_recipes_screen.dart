import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/analytics/application/recipe_analytics_service.dart';
import 'package:foodiy/features/chef/application/chef_recipes_service.dart';
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
    final service = ChefRecipesService.instance;
    final recipes = service.getMyRecipes();
    final analytics = RecipeAnalyticsService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My recipes'),
        leading: const BackButton(),
      ),
      body: recipes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('You have not published any recipes yet'),
              ),
            )
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final views = analytics.getTotalViewsForRecipes(<String>[
                  recipe.id,
                ]);
                final adds = analytics.getTotalPlaylistAddsForRecipes(<String>[
                  recipe.id,
                ]);
                return ListTile(
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        recipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) {
                          return Container(
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(Icons.restaurant, size: 32),
                          );
                        },
                      ),
                    ),
                  ),
                  title: Text(recipe.title),
                  subtitle: Text(
                    '${recipe.time} • ${recipe.difficulty}\nViews: $views • Saves: $adds',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // TODO: Implement edit recipe flow (open RecipeUploadScreen in edit mode).
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Edit recipe is not implemented yet',
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          ChefRecipesService.instance.removeRecipe(recipe.id);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Recipe "${recipe.title}" deleted'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    final localeCode =
                        Localizations.localeOf(context).languageCode;
                    context.push(
                      AppRoutes.recipeDetails,
                      extra: RecipeDetailsArgs(
                        id: recipe.id,
                        title: recipe.title,
                        imageUrl: recipe.imageUrl,
                        time: recipe.time,
                        difficulty: recipe.difficulty,
                        originalLanguageCode: localeCode,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

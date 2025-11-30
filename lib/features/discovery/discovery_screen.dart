import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/models/recipe.dart';
import 'package:foodiy/services/recipe_firestore_service.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('foodiy - Discovery'),
      ),
      body: _RecipeFeed(service: RecipeFirestoreService()),
    );
  }
}

class _RecipeFeed extends StatelessWidget {
  const _RecipeFeed({required this.service});

  final RecipeFirestoreService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Recipe>>(
      stream: service.watchRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong loading recipes.'),
          );
        }

        final recipes = snapshot.data ?? const <Recipe>[];
        if (recipes.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No recipes yet. Save your favorites to see them here!',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _NavigationButtons(onNavigate: context.go),
            ],
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: recipes.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == recipes.length) {
              return _NavigationButtons(onNavigate: context.go);
            }
            final recipe = recipes[index];
            return _RecipeCard(recipe: recipe);
          },
        );
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.image,
                  size: 48,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              recipe.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              recipe.chefName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              recipe.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Text(
              recipe.tags.join(' · '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationButtons extends StatelessWidget {
  const _NavigationButtons({required this.onNavigate});

  final void Function(String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => onNavigate('/recipe'),
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Recipes'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => onNavigate('/chef'),
                icon: const Icon(Icons.person),
                label: const Text('Chefs'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => onNavigate('/playlists'),
                icon: const Icon(Icons.queue_music),
                label: const Text('Playlists'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => onNavigate('/shopping'),
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Shop'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

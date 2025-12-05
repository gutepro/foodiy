import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/recipe/domain/recipe_step.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_player_screen.dart';
import 'package:foodiy/router/app_routes.dart';

class PlaylistDetailsArgs {
  final String title;
  final String imageUrl;
  final String description;
  final String totalTime;
  final List<PlaylistRecipeItem> recipes;

  const PlaylistDetailsArgs({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.totalTime,
    required this.recipes,
  });
}

class PlaylistDetailsScreen extends StatelessWidget {
  const PlaylistDetailsScreen({super.key, required this.args});

  final PlaylistDetailsArgs args;

  List<RecipeStep> _buildMockPlaylistSteps(PlaylistDetailsArgs args) {
    return const [
      RecipeStep(
        text: 'Prepare ingredients for the first recipe.',
        durationSeconds: null,
      ),
      RecipeStep(
        text: 'Cook the first recipe according to its instructions.',
        durationSeconds: 10 * 60,
      ),
      RecipeStep(
        text: 'Prepare the next recipe in the playlist.',
        durationSeconds: null,
      ),
      RecipeStep(
        text: 'Cook the rest of the playlist.',
        durationSeconds: 20 * 60,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(args.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                args.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              args.title,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(args.description),
            const SizedBox(height: 8),
            Text(
              '${args.recipes.length} recipes • ${args.totalTime}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                final steps = _buildMockPlaylistSteps(args);
                final playerArgs = RecipePlayerArgs(
                  title: 'Playlist - ${args.title}',
                  imageUrl: args.imageUrl,
                  steps: steps,
                  languageCode: 'he',
                );
                context.push(AppRoutes.recipePlayer, extra: playerArgs);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play all'),
            ),
            const SizedBox(height: 16),
            ...args.recipes.map(
              (r) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    r.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.restaurant, size: 32),
                      );
                    },
                  ),
                ),
                  title: Text(r.title),
                  subtitle: Text(r.time),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () {
                    context.push(
                      AppRoutes.recipeDetails,
                      extra: RecipeDetailsArgs(
                        title: r.title,
                        imageUrl: r.imageUrl,
                        time: r.time,
                        difficulty: 'Easy',
                        originalLanguageCode: 'he',
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistRecipeItem {
  final String title;
  final String imageUrl;
  final String time;

  const PlaylistRecipeItem({
    required this.title,
    required this.imageUrl,
    required this.time,
  });
}

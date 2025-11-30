import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/playlist/presentation/screens/playlist_details_screen.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';
import 'package:foodiy/router/app_routes.dart';

class SearchResultsArgs {
  final String query;
  const SearchResultsArgs({required this.query});
}

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key, required this.args});

  final SearchResultsArgs args;

  bool _matches(String text, String query) =>
      text.toLowerCase().contains(query.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final recipes = _mockRecipes
        .where((r) => _matches(r.title, args.query))
        .toList();
    final playlists = _mockPlaylists
        .where((p) => _matches(p.title, args.query))
        .toList();
    final chefs = _mockChefs.where((c) => _matches(c.name, args.query)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
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
            Text('Results for: ${args.query}', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _Section(
              title: 'Recipes',
              child: recipes.isEmpty
                  ? const Text('No recipes found')
                  : Column(
                      children: recipes
                          .map(
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
                                  ),
                                ),
                                title: Text(r.title),
                                subtitle: Text(r.time),
                                onTap: () {
                                  context.push(
                                    AppRoutes.recipeDetails,
                                    extra: RecipeDetailsArgs(
                                      title: r.title,
                                      imageUrl: r.imageUrl,
                                      time: r.time,
                                      difficulty: 'Easy',
                                      originalLanguageCode: localeCode,
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Playlists',
              child: playlists.isEmpty
                  ? const Text('No playlists found')
                  : Column(
                      children: playlists
                          .map(
                            (p) => Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    p.imageUrl,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(p.title),
                                subtitle: Text(p.subtitle),
                                onTap: () {
                                  final args = PlaylistDetailsArgs(
                                    title: p.title,
                                    imageUrl: p.imageUrl,
                                    description: p.description,
                                    totalTime: p.totalTime,
                                    recipes: const [
                                      PlaylistRecipeItem(
                                        title: 'Sample recipe',
                                        imageUrl:
                                            'https://via.placeholder.com/120x120',
                                        time: '20 min',
                                      ),
                                    ],
                                  );
                                  context.push(AppRoutes.playlistDetails, extra: args);
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Chefs',
              child: chefs.isEmpty
                  ? const Text('No chefs found')
                  : Column(
                      children: chefs
                          .map(
                            (c) => ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade300,
                                child:
                                    Icon(Icons.person, color: Colors.grey.shade600),
                              ),
                              title: Text(c.name),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Chef profile coming soon'),
                                  ),
                                );
                              },
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _MockRecipe {
  final String title;
  final String imageUrl;
  final String time;
  const _MockRecipe({
    required this.title,
    required this.imageUrl,
    required this.time,
  });
}

class _MockPlaylist {
  final String title;
  final String imageUrl;
  final String subtitle;
  final String description;
  final String totalTime;

  const _MockPlaylist({
    required this.title,
    required this.imageUrl,
    required this.subtitle,
    required this.description,
    required this.totalTime,
  });
}

class _MockChef {
  final String name;
  const _MockChef(this.name);
}

const _mockRecipes = [
  _MockRecipe(
    title: 'Pasta Bolognese',
    imageUrl: 'https://via.placeholder.com/140x140',
    time: '25 min',
  ),
  _MockRecipe(
    title: 'Grilled chicken skewers',
    imageUrl: 'https://via.placeholder.com/140x140',
    time: '20 min',
  ),
  _MockRecipe(
    title: 'Shakshuka',
    imageUrl: 'https://via.placeholder.com/140x140',
    time: '30 min',
  ),
];

const _mockPlaylists = [
  _MockPlaylist(
    title: 'Weeknight Pasta Hits',
    imageUrl: 'https://via.placeholder.com/400x240',
    subtitle: '5 recipes • 45 min total',
    description: 'Comforting pasta picks for busy nights.',
    totalTime: '45 min',
  ),
  _MockPlaylist(
    title: 'Family BBQ Night',
    imageUrl: 'https://via.placeholder.com/400x240',
    subtitle: '6 recipes • 60 min total',
    description: 'Grill-friendly plates everyone loves.',
    totalTime: '60 min',
  ),
  _MockPlaylist(
    title: 'Quick Lunch Boost',
    imageUrl: 'https://via.placeholder.com/400x240',
    subtitle: '4 recipes • 30 min total',
    description: 'Fast, satisfying midday bites.',
    totalTime: '30 min',
  ),
];

const _mockChefs = [
  _MockChef('Chef Lila'),
  _MockChef('Chef Mateo'),
  _MockChef('Chef Priya'),
  _MockChef('Chef Devon'),
];

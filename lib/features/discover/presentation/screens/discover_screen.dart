import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/features/playlist/presentation/screens/playlist_details_screen.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selectedCategory = 'All';

  static const _categories = [
    'All',
    'Quick lunch',
    'Kids',
    'On the grill',
    'Pasta',
    'Healthy',
    'Desserts',
  ];

  static const _mockPlaylists = [
    _MockPlaylist(
      title: 'Weeknight Pasta Hits',
      imageUrl: 'https://via.placeholder.com/400x240',
      subtitle: '5 recipes • 45 min total',
      description: 'Comforting pasta picks for busy nights.',
      totalTime: '45 min',
      category: 'Pasta',
    ),
    _MockPlaylist(
      title: 'Family BBQ Night',
      imageUrl: 'https://via.placeholder.com/400x240',
      subtitle: '6 recipes • 60 min total',
      description: 'Grill-friendly plates everyone loves.',
      totalTime: '60 min',
      category: 'On the grill',
    ),
    _MockPlaylist(
      title: 'Quick Lunch Boost',
      imageUrl: 'https://via.placeholder.com/400x240',
      subtitle: '4 recipes • 30 min total',
      description: 'Fast, satisfying midday bites.',
      totalTime: '30 min',
      category: 'Quick lunch',
    ),
  ];

  static const _mockChefs = [
    _MockChef(name: 'Chef Lila', imageUrl: ''),
    _MockChef(name: 'Chef Mateo', imageUrl: ''),
    _MockChef(name: 'Chef Priya', imageUrl: ''),
    _MockChef(name: 'Chef Devon', imageUrl: ''),
  ];

  static const _mockRecipes = [
    _MockRecipe(
      title: 'Pesto Primavera',
      imageUrl: 'https://via.placeholder.com/140x140',
      time: '20 min',
    ),
    _MockRecipe(
      title: 'Citrus Salmon',
      imageUrl: 'https://via.placeholder.com/140x140',
      time: '25 min',
    ),
    _MockRecipe(
      title: 'Spiced Veggie Bowl',
      imageUrl: 'https://via.placeholder.com/140x140',
      time: '18 min',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final filteredPlaylists = _selectedCategory == 'All'
        ? _mockPlaylists
        : _mockPlaylists
            .where((p) => p.category == _selectedCategory)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.search),
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse by category',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < _categories.length; i++) ...[
                      _CategoryChip(
                        label: _categories[i],
                        isSelected: _selectedCategory == _categories[i],
                        onTap: () {
                          setState(() {
                            _selectedCategory = _categories[i];
                          });
                        },
                      ),
                      if (i != _categories.length - 1) const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Recommended playlists',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Column(
              children: filteredPlaylists
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlaylistCard(
                        playlist: p,
                        onView: () {
                          final args = PlaylistDetailsArgs(
                            title: p.title,
                            imageUrl: p.imageUrl,
                            description: p.description,
                            totalTime: p.totalTime,
                            recipes: [
                              PlaylistRecipeItem(
                                title: 'Sample recipe',
                                imageUrl: 'https://via.placeholder.com/120x120',
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
            const SizedBox(height: 24),
            Text(
              'Popular chefs',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _mockChefs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final chef = _mockChefs[index];
                  return GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chef profile coming soon')),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          chef.name,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Because you like...',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _mockRecipes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final recipe = _mockRecipes[index];
                  return SizedBox(
                    width: 150,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          context.push(
                            AppRoutes.recipeDetails,
                            extra: RecipeDetailsArgs(
                              title: recipe.title,
                              imageUrl: recipe.imageUrl,
                              time: recipe.time,
                              difficulty: 'Easy',
                              originalLanguageCode: localeCode,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                recipe.imageUrl,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.title,
                                    style: theme.textTheme.bodyMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recipe.time,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isSelected ? theme.colorScheme.primary : Colors.white;
    final fg = isSelected ? Colors.white : Colors.black87;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist, required this.onView});

  final _MockPlaylist playlist;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onView,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  playlist.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: onView,
                          child: const Text('View'),
                        ),
                        const Spacer(),
                        const Icon(Icons.play_arrow),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockPlaylist {
  final String title;
  final String imageUrl;
  final String subtitle;
  final String description;
  final String totalTime;
  final String category;

  const _MockPlaylist({
    required this.title,
    required this.imageUrl,
    required this.subtitle,
    required this.description,
    required this.totalTime,
    required this.category,
  });
}

class _MockChef {
  final String name;
  final String imageUrl;

  const _MockChef({
    required this.name,
    required this.imageUrl,
  });
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

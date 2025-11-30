import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/features/playlist/presentation/screens/playlist_details_screen.dart';
import 'package:foodiy/shared/widgets/foodiy_logo.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';

class _MockRecipe {
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;

  const _MockRecipe({
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
  });
}

const List<_MockRecipe> _mockRecipes = [
  _MockRecipe(
    title: 'Pasta Bolognese',
    imageUrl: 'https://via.placeholder.com/160x120',
    time: '25 min',
    difficulty: 'Easy',
  ),
  _MockRecipe(
    title: 'Grilled chicken skewers',
    imageUrl: 'https://via.placeholder.com/160x120',
    time: '20 min',
    difficulty: 'Easy',
  ),
  _MockRecipe(
    title: 'Shakshuka',
    imageUrl: 'https://via.placeholder.com/160x120',
    time: '30 min',
    difficulty: 'Medium',
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _categories = [
    'Quick lunch',
    'Kids love it',
    'On the grill',
    'Pasta',
    'Healthy',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const darkGreen = Color(0xFF1B4332);
    const warmOrange = Color(0xFFEF8354);
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Only show this for chef users.
          context.push(AppRoutes.recipeCreate);
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    height: 48,
                    width: 48,
                    child: FoodiyLogo(),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.push(AppRoutes.search),
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < _categories.length; i++) ...[
                      _CategoryChip(
                        label: _categories[i],
                        selected: i == 0,
                        selectedColor: warmOrange,
                        textColor: darkGreen,
                      ),
                      if (i != _categories.length - 1) const SizedBox(width: 12),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _HeroPlaylistCard(
                title: 'Family pasta dinner',
                tags: const ['30 min', 'Family', 'On the stove'],
                accentColor: warmOrange,
                onTap: () {
                  // TODO: Later connect hero playlist to real data instead of mock.
                  final args = PlaylistDetailsArgs(
                    title: 'Family pasta dinner',
                    imageUrl:
                        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80',
                    description: 'Cozy pasta favorites for the whole family.',
                    totalTime: '45 min',
                    recipes: const [
                      PlaylistRecipeItem(
                        title: 'Pasta Bolognese',
                        imageUrl: 'https://via.placeholder.com/140x140',
                        time: '25 min',
                      ),
                    ],
                  );
                  context.push(AppRoutes.playlistDetails, extra: args);
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Trending recipes',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: darkGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mockRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = _mockRecipes[index];
                  return Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        context.push(
                          AppRoutes.recipeDetails,
                          extra: RecipeDetailsArgs(
                            title: recipe.title,
                            imageUrl: recipe.imageUrl,
                            time: recipe.time,
                            difficulty: recipe.difficulty,
                            originalLanguageCode: localeCode,
                          ),
                        );
                      },
                      child: _RecipeCard(
                        recipe: recipe,
                        accentColor: warmOrange,
                        darkColor: darkGreen,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.textColor,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = selected ? selectedColor : Colors.white;
    final fgColor = selected ? Colors.white : textColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selectedColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: fgColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HeroPlaylistCard extends StatelessWidget {
  const _HeroPlaylistCard({
    required this.title,
    required this.tags,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final List<String> tags;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tags
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: accentColor,
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.accentColor,
    required this.darkColor,
  });

  final _MockRecipe recipe;
  final Color accentColor;
  final Color darkColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                recipe.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: darkColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(label: recipe.time, color: accentColor),
                      _InfoChip(label: recipe.difficulty, color: accentColor),
                      const _InfoChip(label: 'Pan', color: Colors.black54),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

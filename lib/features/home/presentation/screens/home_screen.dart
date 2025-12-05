import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/core/widgets/recipe_image.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/playlist/domain/personal_playlist_models.dart';
import 'package:foodiy/features/playlist/presentation/screens/personal_playlist_details_screen.dart';
import 'package:foodiy/shared/widgets/foodiy_logo.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_upload_screen.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _CookbookTile extends StatelessWidget {
  const _CookbookTile({
    required this.playlist,
    required this.recipeCount,
    required this.onOpen,
  });

  final PersonalPlaylist playlist;
  final int recipeCount;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final isFavorite = playlist.name.toLowerCase() == 'favorite recipes';
    final card = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFavorite)
            Container(
              height: 120,
              color: Colors.pink.shade100,
              alignment: Alignment.center,
              child: const Icon(Icons.favorite, color: Colors.pink, size: 36),
            )
          else
            RecipeImage(
              imageUrl: playlist.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              playlist.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
    return InkWell(
      onTap: onOpen,
      child: card,
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final _playlistService = PersonalPlaylistService.instance;

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B4332);
    const warmOrange = Color(0xFFEF8354);
    final localeCode = Localizations.localeOf(context).languageCode;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const RecipeUploadScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        heroTag: 'home-fab',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(height: 48, width: 48, child: FoodiyLogo()),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.push(AppRoutes.shoppingList),
                    icon: const Icon(Icons.shopping_cart_outlined),
                    tooltip: 'Shopping list',
                  ),
                  IconButton(
                    onPressed: () => context.push(AppRoutes.search),
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _MyRecipesSection(
                      uid: uid,
                      accentColor: warmOrange,
                      darkColor: darkGreen,
                      localeCode: localeCode,
                      onSeeAll: () => _openMyRecipes(
                        uid: uid,
                        accentColor: warmOrange,
                        darkColor: darkGreen,
                        localeCode: localeCode,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _MyPlaylistsSection(
                      playlists: _playlistService.playlists,
                      getEntries: _playlistService.getEntries,
                      onSeeAll: _openMyPlaylists,
                      onOpenPlaylist: _openPlaylistDetails,
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

  Future<void> _openMyRecipes({
    required String uid,
    required Color accentColor,
    required Color darkColor,
    required String localeCode,
  }) async {
    if (uid.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _UserRecipesScreen(
          uid: uid,
          accentColor: accentColor,
          darkColor: darkColor,
          localeCode: localeCode,
        ),
      ),
    );
  }

  Future<void> _openMyPlaylists() async {
    await context.push(AppRoutes.myPlaylists);
    setState(() {});
  }

  Future<void> _openPlaylistDetails(String playlistId) async {
    await context.push(
      AppRoutes.myPlaylistsDetails,
      extra: PersonalPlaylistDetailsArgs(playlistId: playlistId),
    );
    setState(() {});
  }
}

class _MyRecipesSection extends StatelessWidget {
  const _MyRecipesSection({
    required this.uid,
    required this.accentColor,
    required this.darkColor,
    required this.localeCode,
    required this.onSeeAll,
  });

  final String uid;
  final Color accentColor;
  final Color darkColor;
  final String localeCode;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) {
      return const Text('My recipes are available after you sign in.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'My recipes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Recipe>>(
          stream: FirebaseFirestore.instance
              .collection('recipes')
              .where('chefId', isEqualTo: uid)
              .orderBy('createdAt', descending: true)
              .limit(6)
              .snapshots()
              .map((snapshot) => snapshot.docs.map((doc) {
                    final data = doc.data();
                    data['id'] = doc.id;
                    return Recipe.fromJson(data, docId: doc.id);
                  }).toList()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              debugPrint('HomeFeed error: ${snapshot.error}');
              return const Text('Failed to load recipes');
            }
            final recipes = snapshot.data ?? [];
            debugPrint(
              'Home MyRecipes: loaded ${recipes.length} recipes for uid=$uid',
            );
            if (recipes.isEmpty) {
              return const Text(
                'No recipes yet. Tap + to create your first recipe.',
              );
            }
            return GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return _RecipeTile(
                  recipe: recipe,
                  accentColor: accentColor,
                  darkColor: darkColor,
                  localeCode: localeCode,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _MyPlaylistsSection extends StatelessWidget {
  const _MyPlaylistsSection({
    required this.playlists,
    required this.getEntries,
    required this.onSeeAll,
    required this.onOpenPlaylist,
  });

  final List<PersonalPlaylist> playlists;
  final List<PersonalPlaylistEntry> Function(String) getEntries;
  final VoidCallback onSeeAll;
  final void Function(String playlistId) onOpenPlaylist;

  @override
  Widget build(BuildContext context) {
    final topPlaylists = playlists.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'My cookbooks',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton(
              onPressed: playlists.isEmpty ? null : onSeeAll,
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (playlists.isEmpty)
          const Text('No cookbooks yet. Create one from the cookbooks tab.')
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topPlaylists.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final playlist = topPlaylists[index];
              final entries = getEntries(playlist.id);
              return _CookbookTile(
                playlist: playlist,
                recipeCount: entries.length,
                onOpen: () => onOpenPlaylist(playlist.id),
              );
            },
          ),
      ],
    );
  }
}

class _UserRecipesScreen extends StatelessWidget {
  const _UserRecipesScreen({
    required this.uid,
    required this.accentColor,
    required this.darkColor,
    required this.localeCode,
  });

  final String uid;
  final Color accentColor;
  final Color darkColor;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My recipes')),
      body: StreamBuilder<List<Recipe>>(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .where('chefId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) => snapshot.docs.map((doc) {
                  final data = doc.data();
                  data['id'] = doc.id;
                  return Recipe.fromJson(data, docId: doc.id);
                }).toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load recipes'));
          }
          final recipes = snapshot.data ?? [];
          if (recipes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No recipes yet. Tap + to create your first recipe.',
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return _RecipeCard(
                recipe: recipe,
                accentColor: accentColor,
                darkColor: darkColor,
                localeCode: localeCode,
              );
            },
          );
        },
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
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.restaurant, size: 32),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
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
    required this.localeCode,
  });

  final Recipe recipe;
  final Color accentColor;
  final Color darkColor;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return _RecipeTile(
      recipe: recipe,
      accentColor: accentColor,
      darkColor: darkColor,
      localeCode: localeCode,
    );
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({
    required this.recipe,
    required this.accentColor,
    required this.darkColor,
    required this.localeCode,
  });

  final Recipe recipe;
  final Color accentColor;
  final Color darkColor;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
            ingredients: const [],
            steps: const [],
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeImage(
              imageUrl: recipe.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                recipe.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: darkColor,
                    ),
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
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

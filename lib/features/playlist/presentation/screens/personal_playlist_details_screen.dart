import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_share_helper.dart';
import 'package:foodiy/features/playlist/domain/personal_playlist_models.dart';
import 'package:foodiy/features/recipe/application/recipe_firestore_service.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/features/analytics/application/recipe_analytics_service.dart';

class PersonalPlaylistDetailsArgs {
  final String playlistId;
  const PersonalPlaylistDetailsArgs({required this.playlistId});
}

class PersonalPlaylistDetailsScreen extends StatefulWidget {
  const PersonalPlaylistDetailsScreen({super.key, required this.args});

  final PersonalPlaylistDetailsArgs args;

  @override
  State<PersonalPlaylistDetailsScreen> createState() =>
      _PersonalPlaylistDetailsScreenState();
}

class _PersonalPlaylistDetailsScreenState
    extends State<PersonalPlaylistDetailsScreen> {
  final _service = PersonalPlaylistService.instance;

  @override
  Widget build(BuildContext context) {
    final maybePlaylist = _service.playlists
        .where((p) => p.id == widget.args.playlistId)
        .toList(growable: false);
    if (maybePlaylist.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This cookbook no longer exists')),
        );
        Navigator.of(context).maybePop();
      });
      return const Scaffold();
    }
    final playlist = maybePlaylist.first;
    final entries = _service.getEntries(widget.args.playlistId);

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share cookbook',
            onPressed: () {
              final text = PersonalPlaylistShareHelper.formatPlaylist(
                playlist,
                _service,
              );
              Share.share(text, subject: 'Cookbook: ${playlist.name}');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (playlist.ownerId.isNotEmpty &&
              playlist.ownerId != FirebaseAuth.instance.currentUser?.uid)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Save to my cookbooks'),
                  onPressed: () async {
                    final newPlaylist = _service.createPlaylist(
                      playlist.name,
                      isPublic: playlist.isPublic,
                      imageUrl: playlist.imageUrl,
                    );
                    for (final entry in entries) {
                      _service.addEntry(
                        newPlaylist.id,
                        PersonalPlaylistEntry(
                          recipeId: entry.recipeId,
                          title: entry.title,
                          imageUrl: entry.imageUrl,
                          time: entry.time,
                          difficulty: entry.difficulty,
                        ),
                      );
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Saved "${playlist.name}" to your cookbooks'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add recipes to cookbook'),
                onPressed: () => _onAddRecipesPressed(playlist),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('No recipes in this cookbook yet'))
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final e = entries[index];
                      return ListTile(
                        leading: SizedBox(
                          width: 56,
                          height: 56,
                          child: Image.network(
                            e.imageUrl,
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
                        title: Text(e.title),
                        subtitle: Text('${e.time} • ${e.difficulty}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _service.removeEntry(playlist.id, e.recipeId);
                            setState(() {});
                          },
                        ),
                        onTap: () {
                          context.push(
                            AppRoutes.recipeDetails,
                            extra: RecipeDetailsArgs(
                              id: e.recipeId,
                              title: e.title,
                              imageUrl: e.imageUrl,
                              time: e.time,
                              difficulty: e.difficulty,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAddRecipesPressed(PersonalPlaylist playlist) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final selected = await showModalBottomSheet<Recipe?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final stream = uid.isNotEmpty
            ? RecipeFirestoreService.instance.watchUserRecipes(uid: uid)
            : RecipeFirestoreService.instance.watchAllRecipes();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select a recipe to add',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: StreamBuilder<List<Recipe>>(
                    stream: stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Failed to load recipes'));
                      }
                      final recipes = snapshot.data ?? const [];
                      if (recipes.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No recipes available to add.'),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          final r = recipes[index];
                          final time = '${r.steps.length} steps';
                          return ListTile(
                            leading: const Icon(Icons.restaurant_menu),
                            title: Text(r.title),
                            subtitle: Text(time),
                            onTap: () => Navigator.of(context).pop(r),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null) return;

    final entry = PersonalPlaylistEntry(
      recipeId: selected.id,
      title: selected.title,
      imageUrl: selected.imageUrl,
      time: '${selected.steps.length} steps',
      difficulty: '-',
    );
    _service.addEntry(playlist.id, entry);
    RecipeAnalyticsService.instance.recordPlaylistAdd(selected.id);

    setState(() {});
  }
}

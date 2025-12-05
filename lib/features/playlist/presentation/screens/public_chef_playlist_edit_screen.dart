import 'package:flutter/material.dart';

import 'package:foodiy/features/chef/application/chef_recipes_service.dart';
import 'package:foodiy/features/playlist/application/public_chef_playlist_service.dart';
import 'package:foodiy/features/playlist/domain/public_chef_playlist_models.dart';

class PublicChefPlaylistEditScreen extends StatefulWidget {
  const PublicChefPlaylistEditScreen({super.key});

  @override
  State<PublicChefPlaylistEditScreen> createState() =>
      _PublicChefPlaylistEditScreenState();
}

class _PublicChefPlaylistEditScreenState
    extends State<PublicChefPlaylistEditScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _selectedIds = <String>{};

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ChefRecipesService.instance.getMyRecipes();

    return Scaffold(
      appBar: AppBar(title: const Text('Create public cookbook')),
      body: recipes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'You have no recipes to add yet.\nUpload recipes to create a public cookbook.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Playlist title',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select recipes to include',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: recipes.map((recipe) {
                        final isSelected = _selectedIds.contains(recipe.id);
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedIds.add(recipe.id);
                              } else {
                                _selectedIds.remove(recipe.id);
                              }
                            });
                          },
                          title: Text(recipe.title),
                          subtitle: Text(
                            '${recipe.time} • ${recipe.difficulty}',
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.public),
                      label: const Text('Create public cookbook'),
                      onPressed: _onCreatePressed,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _onCreatePressed() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final recipes = ChefRecipesService.instance.getMyRecipes();

    if (title.isEmpty) {
      _showMessage('Please enter a playlist title');
      return;
    }
    if (_selectedIds.isEmpty) {
      _showMessage('Select at least one recipe');
      return;
    }

    final entries = recipes
        .where((r) => _selectedIds.contains(r.id))
        .map(
          (r) => PublicChefPlaylistEntry(
            recipeId: r.id,
            title: r.title,
            imageUrl: r.imageUrl,
            time: r.time,
            difficulty: r.difficulty,
          ),
        )
        .toList(growable: false);

    await PublicChefPlaylistService.instance.createPlaylist(
      title: title,
      description: description,
      entries: entries,
    );

    _showMessage('Public playlist created');
    Navigator.of(context).maybePop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:foodiy/features/playlist/application/public_chef_playlist_service.dart';
import 'package:foodiy/features/playlist/domain/public_chef_playlist_models.dart';
import 'package:foodiy/features/recipe/application/recipe_firestore_service.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/shared/constants/categories.dart';

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
  final _selectedCategories = <String>{};
  String? _categoryError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _atCategoryLimit => _selectedCategories.length >= 5;

  void _toggleCategory(String category, bool selected) {
    setState(() {
      if (selected) {
        if (_selectedCategories.contains(category)) return;
        if (_atCategoryLimit) {
          _categoryError = 'Pick up to 5 categories';
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can select up to 5 categories')),
          );
          return;
        }
        _selectedCategories.add(category);
        _categoryError = null;
      } else {
        _selectedCategories.remove(category);
        if (_selectedCategories.isNotEmpty) {
          _categoryError = null;
        }
      }
    });
  }

  bool _validateCategories() {
    if (_selectedCategories.isEmpty) {
      setState(() {
        _categoryError = 'Pick 1-5 categories to publish';
      });
      return false;
    }
    if (_selectedCategories.length > 5) {
      setState(() {
        _categoryError = 'Pick at most 5 categories';
      });
      return false;
    }
    setState(() {
      _categoryError = null;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Create public cookbook')),
      body: uid.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'You have no recipes to add yet.\nUpload recipes to create a public cookbook.',
                  textAlign: TextAlign.center,
                ),
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
                  return const Center(
                    child: Text('Failed to load recipes. Please try again.'),
                  );
                }
                final recipes = snapshot.data ?? const <Recipe>[];
                if (recipes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'You have no recipes to add yet.\nUpload recipes to create a public cookbook.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return Padding(
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
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...[
                            ...kRecipeCategoryOptions.map((c) => c.key),
                            ..._selectedCategories
                                .where(
                                  (c) => !kRecipeCategoryOptions
                                      .any((opt) => opt.key == c),
                                ),
                          ].map((category) {
                            final selected =
                                _selectedCategories.contains(category);
                            final atLimit =
                                _atCategoryLimit && !selected;
                            return FilterChip(
                              label: Text(
                                kCategoryTitleByKey[category] ?? category,
                              ),
                              selected: selected,
                              onSelected: (value) {
                                if (value && atLimit) {
                                  _toggleCategory(category, value);
                                  return;
                                }
                                _toggleCategory(category, value);
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pick 1-5 categories to help people find this cookbook.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (_categoryError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _categoryError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
                                '${recipe.steps.length} steps • Medium',
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
                          onPressed: () => _onCreatePressed(recipes),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _onCreatePressed(List<Recipe> recipes) async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      _showMessage('Please enter a playlist title');
      return;
    }
    if (!_validateCategories()) {
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
            imageUrl: r.imageUrl ?? '',
            time: '${r.steps.length} steps',
            difficulty: 'Medium',
          ),
        )
        .toList(growable: false);

    try {
      await PublicChefPlaylistService.instance.createPlaylist(
        title: title,
        description: description,
        entries: entries,
        categories: _selectedCategories.toList(growable: false),
      );
    } catch (e) {
      _showMessage('Failed to create cookbook: $e');
      return;
    }

    _showMessage('Public playlist created');
    Navigator.of(context).maybePop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

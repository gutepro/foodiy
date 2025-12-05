import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:foodiy/features/analytics/application/recipe_analytics_service.dart';
import 'package:foodiy/core/services/access_control_service.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/core/widgets/recipe_image.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/playlist/domain/personal_playlist_models.dart';
import 'package:foodiy/features/recipe/application/recipe_firestore_service.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/features/recipe/domain/recipe_step.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_upload_screen.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_player_screen.dart';
import 'package:foodiy/features/profile/application/user_profile_service.dart';
import 'package:foodiy/features/profile/domain/user_profile_models.dart';
import 'package:foodiy/features/shopping/application/shopping_list_service.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/features/shopping/application/shopping_list_service.dart'
    show ShoppingListItem;

class RecipeDetailsArgs {
  final String id;
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;
  final String originalLanguageCode;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  const RecipeDetailsArgs({
    this.id = '',
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
    this.originalLanguageCode = 'he',
    this.ingredients = const [],
    this.steps = const [],
  });
}

class RecipeDetailsScreen extends StatefulWidget {
  const RecipeDetailsScreen({super.key, required this.args});

  final RecipeDetailsArgs args;

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final _profileService = UserProfileService.instance;
  final _playlistService = PersonalPlaylistService.instance;
  bool _viewRecorded = false;
  Recipe? _recipe;
  bool _isLoading = true;
  String? _favoritesPlaylistId;
  bool _isFavorited = false;

  Recipe _buildRecipeFromArgs(RecipeDetailsArgs args) {
    return Recipe(
      id: args.id,
      originalLanguageCode: args.originalLanguageCode,
      title: args.title,
      imageUrl: args.imageUrl,
      steps: args.steps,
      ingredients: args.ingredients,
      tools: const [],
      preCookingNotes: '',
      chefId: '',
      chefName: null,
      chefAvatarUrl: null,
      views: 0,
      playlistAdds: 0,
      isPublic: true,
    );
  }
  @override
  void initState() {
    super.initState();
    final args = widget.args;
    debugPrint('RecipeDetailsScreen: args.id=${args.id}');
    if (args.id.isEmpty) {
      setState(() {
        _recipe = _buildRecipeFromArgs(args);
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_viewRecorded) return;
        _viewRecorded = true;
      });
      return;
    }

    RecipeFirestoreService.instance
        .getRecipeById(args.id)
        .then((loadedRecipe) {
      if (!mounted) return;
      setState(() {
        _recipe = loadedRecipe;
        _isLoading = false;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() {
        _recipe = null;
        _isLoading = false;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_viewRecorded) return;
      if (args.id.isNotEmpty) {
        RecipeAnalyticsService.instance.recordView(args.id);
      }
      _viewRecorded = true;
    });
  }

  TextDirection _directionFromLanguage(String code) {
    const rtlLanguages = ['he', 'ar', 'fa', 'ur'];
    if (rtlLanguages.contains(code.toLowerCase())) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recipe == null) {
      return const Scaffold(
        body: Center(child: Text('Recipe not found')),
      );
    }

    final recipe = _recipe!;
    final ingredients = recipe.ingredients;
    final steps = recipe.steps;
    final tools = recipe.tools;
    final canEdit =
        recipe.chefId.isNotEmpty &&
        recipe.chefId == FirebaseAuth.instance.currentUser?.uid;

    return Directionality(
      textDirection: _directionFromLanguage(recipe.originalLanguageCode),
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(recipe.title),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit recipe',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecipeUploadScreen(recipe: recipe),
                  ),
                );
              },
            ),
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.redAccent : null,
            ),
            tooltip: 'Favorite cookbook',
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add to cookbook',
            onPressed: _onAddToPlaylistPressed,
          ),
        ],
      ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                child: RecipeImage(
                  imageUrl: recipe.imageUrl,
                  height: 220,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MetaChip(
                          icon: Icons.access_time,
                          label: widget.args.time,
                        ),
                        const SizedBox(width: 8),
                        _MetaChip(
                          icon: Icons.bolt_outlined,
                          label: widget.args.difficulty,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start cooking'),
                        onPressed: () {
                          final playerArgs = RecipePlayerArgs(
                            title: recipe.title,
                            imageUrl: recipe.imageUrl,
                            steps: steps.isNotEmpty ? steps : widget.args.steps,
                            languageCode: recipe.originalLanguageCode,
                          );
                          context.push(
                            AppRoutes.recipePlayer,
                            extra: playerArgs,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Ingredients', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (ingredients.isEmpty)
                      const Text('No ingredients provided')
                    else
                      Column(
                        children: ingredients
                            .map(
                              (item) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.radio_button_unchecked,
                                  size: 18,
                                ),
                                title: Text(item.name),
                                subtitle: Text(
                                  '${item.quantity}${item.unit.isNotEmpty ? ' ${item.unit}' : ''}',
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showIngredientSelectionSheet(ingredients);
                        },
                        child:
                            const Text('Add ingredients to shopping list'),
                      ),
                    ),
                    if (tools.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Tools / Equipment',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Column(
                        children: tools
                            .map(
                              (tool) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.build_outlined),
                                title: Text(tool.name),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text('Steps', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (steps.isEmpty)
                      const Text('No steps provided')
                    else
                      Column(
                        children: List.generate(
                          steps.length,
                          (index) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.1),
                              child: Text(
                                '${index + 1}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(steps[index].text),
                          ),
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
  }

  Future<void> _showIngredientSelectionSheet(
    List<RecipeIngredient> ingredients,
  ) async {
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No ingredients to add')),
      );
      return;
    }

    final selected = List<bool>.filled(ingredients.length, true);

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select ingredients to add',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(ingredients.length, (index) {
                          final ing = ingredients[index];
                          final quantityText =
                              '${ing.quantity}${ing.unit.isNotEmpty ? ' ${ing.unit}' : ''}';
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: selected[index],
                            onChanged: (value) {
                              setSheetState(() {
                                selected[index] = value ?? false;
                              });
                            },
                            title: Text(ing.name),
                            subtitle: quantityText.trim().isNotEmpty
                                ? Text(quantityText)
                                : null,
                          );
                        }),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Add to list'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    final uuid = const Uuid();
    final items = <ShoppingListItem>[];
    for (var i = 0; i < ingredients.length; i++) {
      if (!selected[i]) continue;
      final ing = ingredients[i];
      final quantityText =
          '${ing.quantity}${ing.unit.isNotEmpty ? ' ${ing.unit}' : ''}';
      items.add(
        ShoppingListItem(
          id: uuid.v4(),
          name: ing.name,
          quantity: quantityText,
        ),
      );
    }

    if (items.isEmpty) return;

    ShoppingListService.instance.addItems(items);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selected ingredients added to your shopping list'),
      ),
    );
  }

  Future<void> _onAddToPlaylistPressed() async {
    final selected = await _showChooseCookbookSheet();
    if (selected == null) return;
    await _addRecipeToPlaylist(selected);
  }

  Future<void> _toggleFavorite() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to save favorites')),
      );
      return;
    }
    final favorite = _playlistService.ensureFavoritesPlaylist();
    if (favorite == null) return;
    await _addRecipeToPlaylist(favorite, showMessage: false);
    setState(() {
      _favoritesPlaylistId = favorite.id;
      _isFavorited = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to "${favorite.name}"')),
      );
    }
  }

  PersonalPlaylist? _getOrCreateFavoritesCookbook(String uid) {
    final existing = _playlistService.playlists.firstWhere(
      (p) =>
          p.ownerId == uid &&
          p.name.toLowerCase() == 'favorite recipes'.toLowerCase(),
      orElse: () => PersonalPlaylist(id: '', name: ''),
    );
    if (existing.id.isNotEmpty) {
      return existing;
    }
    final created = _playlistService.createPlaylist(
      'Favorite recipes',
      isPublic: false,
    );
    return created;
  }

  Future<PersonalPlaylist?> _showCreatePlaylistDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create cookbook'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Cookbook name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a name')),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result != true) return null;

    final name = controller.text.trim();
    final playlist = _playlistService.createPlaylist(name);
    return playlist;
  }

  Future<PersonalPlaylist?> _showChooseCookbookSheet() async {
    return showModalBottomSheet<PersonalPlaylist>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _CookbookPicker(
                playlists: _playlistService.getCurrentUserPlaylists(),
                onCreateNew: _showCreatePlaylistDialog,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addRecipeToPlaylist(
    PersonalPlaylist playlist, {
    bool showMessage = true,
  }) async {
    final recipeId = widget.args.id.isNotEmpty
        ? widget.args.id
        : widget.args.title;
    final title = widget.args.title;
    final imageUrl = widget.args.imageUrl;
    final time = widget.args.time;
    final difficulty = widget.args.difficulty;

    final entry = PersonalPlaylistEntry(
      recipeId: recipeId,
      title: title,
      imageUrl: imageUrl,
      time: time,
      difficulty: difficulty,
    );

    _playlistService.addEntry(playlist.id, entry);
    RecipeAnalyticsService.instance.recordPlaylistAdd(entry.recipeId);
    debugPrint(
      'RecipeDetailsScreen: added recipe $recipeId to cookbook "${playlist.name}". '
      'Now has ${_playlistService.getEntries(playlist.id).length} entries.',
    );

    if (showMessage && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added "$title" to "${playlist.name}"')),
      );
    }
  }

  String get _recipeId =>
      widget.args.id.isNotEmpty ? widget.args.id : widget.args.title;

  // TODO: Later add "Add to cookbook" flow to link recipes into user cookbooks.
  // In progress via personal playlists below.
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsSelectionSheet extends StatefulWidget {
  const _IngredientsSelectionSheet({required this.ingredients});

  final List<RecipeIngredient> ingredients;

  @override
  State<_IngredientsSelectionSheet> createState() =>
      _IngredientsSelectionSheetState();
}

class _CookbookPicker extends StatelessWidget {
  const _CookbookPicker({
    required this.playlists,
    required this.onCreateNew,
  });

  final List<PersonalPlaylist> playlists;
  final Future<PersonalPlaylist?> Function() onCreateNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a cookbook',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('New cookbook'),
          onTap: () async {
            final created = await onCreateNew();
            if (created != null && context.mounted) {
              Navigator.of(context).pop(created);
            }
          },
        ),
        const Divider(),
        if (playlists.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('No cookbooks yet. Create one to add this recipe.'),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: playlists.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final pl = playlists[index];
                final isPublic = pl.isPublic;
                return ListTile(
                  leading: pl.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            pl.imageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(Icons.menu_book),
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.menu_book),
                  title: Text(pl.name),
                  subtitle: Text(isPublic ? 'Public' : 'Private'),
                  onTap: () => Navigator.of(context).pop(pl),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _IngredientsSelectionSheetState
    extends State<_IngredientsSelectionSheet> {
  late List<bool> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<bool>.filled(widget.ingredients.length, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select ingredients to add',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.ingredients.length,
                itemBuilder: (context, index) {
                  final ing = widget.ingredients[index];
                  return CheckboxListTile(
                    value: _selected[index],
                    onChanged: (value) {
                      setState(() {
                        _selected[index] = value ?? false;
                      });
                    },
                    title: Text(ing.name),
                    subtitle: ing.quantity.isNotEmpty
                        ? Text(ing.quantity)
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop<Set<int>>({});
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final selectedIndexes = <int>{};
                    for (var i = 0; i < _selected.length; i++) {
                      if (_selected[i]) {
                        selectedIndexes.add(i);
                      }
                    }
                    Navigator.of(context).pop<Set<int>>(selectedIndexes);
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

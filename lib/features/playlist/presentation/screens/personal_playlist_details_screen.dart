import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_share_helper.dart';
import 'package:foodiy/features/playlist/domain/personal_playlist_models.dart';
import 'package:foodiy/features/recipe/application/recipe_firestore_service.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_details_screen.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/features/analytics/application/recipe_analytics_service.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';
import 'package:foodiy/shared/constants/categories.dart';
import 'package:foodiy/core/utils/auth_guards.dart';
import 'package:foodiy/l10n/app_localizations.dart';

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
  Set<String> _lastCheckedRecipeIds = const <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    debugPrint(
      '[L10N] locale=${Localizations.localeOf(context)} screen=personal_playlist_details',
    );
    final maybePlaylist = _service.playlists
        .where((p) => p.id == widget.args.playlistId)
        .toList(growable: false);
    if (maybePlaylist.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cookbooksMissing)),
        );
        Navigator.of(context).maybePop();
      });
      return const Scaffold();
    }
    final playlist = maybePlaylist.first;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('cookbooks')
          .doc(playlist.id)
          .snapshots(),
      builder: (context, cookbookSnap) {
        if (cookbookSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final recipeIds =
            (cookbookSnap.data?.data()?['recipeIds'] as List<dynamic>?)
                    ?.whereType<String>()
                    .toList() ??
                const <String>[];
        debugPrint(
          '[COOKBOOK_DETAILS] cookbookId=${playlist.id} path=cookbooks/${playlist.id} recipeIdsCount=${recipeIds.length}',
        );
        if (recipeIds.isEmpty) {
          return Scaffold(
            appBar: FoodiyAppBar(
              title: Text(playlist.name),
            ),
            body: Center(
              child: Text(l10n.cookbooksNoRecipesYet),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await _onAddRecipesPressed(playlist);
              },
              child: const Icon(Icons.add),
            ),
          );
        }
        return FutureBuilder<List<Recipe>>(
          future: RecipeFirestoreService.instance.fetchRecipesByIds(recipeIds),
          builder: (context, recipesSnap) {
            if (recipesSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final recipes = recipesSnap.data ?? const <Recipe>[];
            final recipeMap = {for (final r in recipes) r.id: r};
            final orderedRecipes = recipeIds
                .map((id) => recipeMap[id])
                .whereType<Recipe>()
                .toList();
            debugPrint(
              '[COOKBOOK_DETAILS] fetchedRecipes=${orderedRecipes.length} for cookbookId=${playlist.id}',
            );
            final entries = orderedRecipes
                .map(
                  (r) => PersonalPlaylistEntry(
                    recipeId: r.id,
                    title: r.title,
                    imageUrl: r.coverImageUrl ?? r.imageUrl ?? '',
                    time: l10n.profileStepsCount(r.steps.length),
                    difficulty: '-',
                  ),
                )
                .toList();
            _maybeCleanupMissingEntries(playlist.id, entries);
            return Scaffold(
              appBar: FoodiyAppBar(
                title: Text(playlist.name),
                actions: [
                  if (playlist.ownerId.isNotEmpty &&
                      playlist.ownerId ==
                          FirebaseAuth.instance.currentUser?.uid)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: l10n.cookbooksActionRename,
                      onPressed: () async {
                        print('[EDIT_COOKBOOK] NAV TAP cookbookId=${playlist.id}');
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => _EditCookbookScreen(playlist: playlist),
                          ),
                        );
                        if (updated == true && mounted) {
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.cookbooksUpdated)),
                          );
                        }
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: l10n.cookbooksActionShare,
                    onPressed: () {
                      final text = PersonalPlaylistShareHelper.formatPlaylist(
                        playlist,
                        _service,
                      );
                      Share.share(
                        text,
                        subject: l10n.cookbooksShareSubject(playlist.name),
                      );
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  if (playlist.ownerId.isNotEmpty &&
                      playlist.ownerId != FirebaseAuth.instance.currentUser?.uid)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save_alt),
                          label: Text(l10n.cookbooksSaveToMy),
                          onPressed: () async {
                            if (isGuestUser) {
                              await ensureNotGuest(context);
                              return;
                            }
                            if (playlist.isPublic &&
                                playlist.categories.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.cookbooksCategoryPublicRequired,
                                  ),
                                ),
                              );
                              return;
                            }
                            final newPlaylist = _service.createPlaylist(
                              playlist.name,
                              isPublic: playlist.isPublic,
                              imageUrl: playlist.imageUrl,
                              categories: playlist.categories,
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
                                  content: Text(
                                    l10n.cookbooksSavedToMy(playlist.name),
                                  ),
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
                        label: Text(
                          AppLocalizations.of(context)!.cookbooksAddRecipes,
                        ),
                        onPressed: () => _onAddRecipesPressed(playlist),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: entries.isEmpty
                        ? Center(
                            child: Text(l10n.cookbooksNoRecipesYet),
                          )
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
                                        child: const Icon(
                                          Icons.restaurant,
                                          size: 32,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                title: Text(e.title),
                                subtitle: Text('${e.time} • ${e.difficulty}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _service.removeEntry(
                                      playlist.id,
                                      e.recipeId,
                                    );
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
          },
        );
      },
    );
  }

  Future<void> _onAddRecipesPressed(PersonalPlaylist playlist) async {
    final l10n = AppLocalizations.of(context)!;
    print(
      '[ADD_TO_COOKBOOK] handler entered for cookbookId=${playlist.id} owner=${playlist.ownerId}',
    );
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final selectedIds = <String>{};
    final stream = uid.isNotEmpty
        ? RecipeFirestoreService.instance.watchUserRecipes(uid: uid)
        : RecipeFirestoreService.instance.watchAllRecipes();
    final selected = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            _AddRecipesScreen(stream: stream, initialSelected: selectedIds),
      ),
    );

    print(
      '[ADD_TO_COOKBOOK] Navigator returned selection '
      '${selected == null ? 'null' : 'count=${selected.length}'}',
    );

    if (selected == null || selected.isEmpty) {
      print('[ADD_TO_COOKBOOK] No recipes selected (null/empty)');
      return;
    }

    print(
      '[ADD_TO_COOKBOOK] Selected ${selected.length} recipes for cookbook=${playlist.id}',
    );

    // Fetch recipe metadata once (avoid waiting on stream).
    List<Recipe> recipes = const [];
    try {
      recipes = await RecipeFirestoreService.instance.fetchUserRecipesOnce(
        uid: uid,
      );
      print(
        '[ADD_TO_COOKBOOK] Fetched ${recipes.length} recipes for add (uid=$uid, cookbook=${playlist.id})',
      );
    } catch (e, st) {
      print('[ADD_TO_COOKBOOK] ERROR fetching recipes for add: $e');
      debugPrint('$st');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            l10n.cookbooksLoadRecipesFailed('$e'),
          ),
        ),
      );
      }
      return;
    }
    final byId = {for (final r in recipes) r.id: r};

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          l10n.cookbooksAddingRecipes,
        ),
      ),
    );

    for (final id in selected) {
      final recipe =
          byId[id] ??
          Recipe(
            id: id,
            originalLanguageCode: '',
            title: l10n.untitledRecipe,
            steps: const [],
            ingredients: const [],
            tools: const [],
          );
      final time = l10n.profileStepsCount(recipe.steps.length);
      final entry = PersonalPlaylistEntry(
        recipeId: id,
        title: recipe.title,
        imageUrl: recipe.imageUrl ?? '',
        time: time,
        difficulty: '-',
      );
      print('[ADD_TO_COOKBOOK] TAP cookbookId=${playlist.id} recipeId=$id');
      try {
        print('[ADD_TO_COOKBOOK] START cookbookId=${playlist.id} recipeId=$id');
        await _service.addEntryAwaitAttach(playlist.id, entry);
        RecipeAnalyticsService.instance.recordPlaylistAdd(id);
        print(
          '[ADD_TO_COOKBOOK] SUCCESS cookbookId=${playlist.id} recipeId=$id',
        );
      } catch (e, st) {
        print(
          '[ADD_TO_COOKBOOK] ERROR cookbookId=${playlist.id} recipeId=$id error=$e',
        );
        debugPrint('$st');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                l10n.cookbooksAddRecipeFailed('$e'),
              ),
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.cookbooksRecipesAdded,
          ),
        ),
      );
    }
  }

  void _maybeCleanupMissingEntries(
    String playlistId,
    List<PersonalPlaylistEntry> entries,
  ) {
    final ids = entries
        .map((e) => e.recipeId)
        .where((id) => id.isNotEmpty)
        .toSet();
    if (ids.isEmpty) {
      _lastCheckedRecipeIds = ids;
      return;
    }
    if (setEquals(ids, _lastCheckedRecipeIds)) return;
    _lastCheckedRecipeIds = ids;
    unawaited(_removeMissingEntries(playlistId, ids));
  }

  Future<void> _removeMissingEntries(
    String playlistId,
    Set<String> recipeIds,
  ) async {
    final existing = await RecipeFirestoreService.instance.getExistingRecipeIds(
      recipeIds,
    );
    final missing = recipeIds.difference(existing);
    if (missing.isEmpty) return;
    for (final id in missing) {
      _service.removeEntry(playlistId, id);
    }
    if (!mounted) return;
    setState(() {});
  }
}

class _AddRecipesScreen extends StatefulWidget {
  const _AddRecipesScreen({
    required this.stream,
    required this.initialSelected,
  });

  final Stream<List<Recipe>> stream;
  final Set<String> initialSelected;

  @override
  State<_AddRecipesScreen> createState() => _AddRecipesScreenState();
}

class _AddRecipesScreenState extends State<_AddRecipesScreen> {
  late final Set<String> _selectedIds = Set<String>.from(
    widget.initialSelected,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: FoodiyAppBar(
        title: Text(l10n.cookbooksSelectRecipes),
        actions: [
          TextButton(
            onPressed: _selectedIds.isEmpty
                ? null
                : () {
                    print(
                      '[ADD_TO_COOKBOOK_UI] AppBar Add tapped, returning ${_selectedIds.length} ids',
                    );
                    Navigator.of(context).pop(_selectedIds);
                  },
            child: Text(l10n.addButton),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Recipe>>(
          stream: widget.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.cookbooksLoadRecipesFailedSimple),
                ),
              );
            }
            final recipes = snapshot.data ?? const [];
            if (recipes.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.cookbooksNoRecipesToAdd),
                ),
              );
            }
            return ListView.separated(
              itemCount: recipes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final r = recipes[index];
                final checked = _selectedIds.contains(r.id);
                final time = l10n.profileStepsCount(r.steps.length);
                return CheckboxListTile(
                  value: checked,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedIds.add(r.id);
                      } else {
                        _selectedIds.remove(r.id);
                      }
                    });
                  },
                  title: Text(r.title),
                  subtitle: Text(time),
                  secondary: const Icon(Icons.restaurant_menu_outlined),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () {
                          print(
                            '[ADD_TO_COOKBOOK_UI] Bottom Add tapped, returning ${_selectedIds.length} ids',
                          );
                          Navigator.of(context).pop(_selectedIds);
                        },
                  child: Text(l10n.addSelected),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditCookbookScreen extends StatefulWidget {
  const _EditCookbookScreen({required this.playlist});

  final PersonalPlaylist playlist;

  @override
  State<_EditCookbookScreen> createState() => _EditCookbookScreenState();
}

class _EditCookbookScreenState extends State<_EditCookbookScreen> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.playlist.name,
  );
  final _picker = ImagePicker();
  String? _pickedImagePath;
  bool _isPublic = false;
  late Set<String> _categories = widget.playlist.categories.toSet();
  String? _nameError;
  String? _categoryError;
  bool _saving = false;

  bool get _atCategoryLimit => _categories.length >= 5;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.playlist.isPublic;
    print('[EDIT_COOKBOOK] initState cookbookId=${widget.playlist.id}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedImagePath = picked.path);
    }
  }

  Future<String> _uploadCover(String cookbookId, String path) async {
    final file = File(path);
    final ref = FirebaseStorage.instance
        .ref()
        .child('cookbook_covers')
        .child(cookbookId)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = ref.putFile(file);
    final snap = await task;
    return snap.ref.getDownloadURL();
  }

  void _toggleCategory(String key, bool selected) {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      if (selected) {
        if (_categories.contains(key)) return;
        if (_atCategoryLimit) {
          _categoryError = l10n.cookbooksCategoryLimit;
          return;
        }
        _categories.add(key);
      } else {
        _categories.remove(key);
      }
      _categoryError = null;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l10n.cookbooksNameRequired);
      return;
    }
    if (_isPublic && _categories.isEmpty) {
      setState(
        () => _categoryError = l10n.cookbooksCategoryPublicRequired,
      );
      return;
    }
    setState(() {
      _saving = true;
      _nameError = null;
      _categoryError = null;
    });
    String imageUrl = widget.playlist.imageUrl;
    try {
      if (_pickedImagePath != null) {
        imageUrl = await _uploadCover(widget.playlist.id, _pickedImagePath!);
      }
      await PersonalPlaylistService.instance.updateCookbook(
        id: widget.playlist.id,
        name: name,
        isPublic: _isPublic,
        imageUrl: imageUrl,
        categories: _categories.toList(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e, st) {
      debugPrint('Edit cookbook failed: $e');
      debugPrint('$st');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(content: Text(l10n.cookbooksSaveFailed('$e'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentImage = _pickedImagePath != null
        ? FileImage(File(_pickedImagePath!))
        : null;
    return Scaffold(
      appBar: FoodiyAppBar(
        title: Text(l10n.cookbooksEditTitle),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.cookbooksSave),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.cookbooksNameLabel,
                        errorText: _nameError,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.cookbooksCoverImage,
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _saving ? null : _pickImage,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Builder(
                              builder: (_) {
                                if (currentImage != null) {
                                  return Image(
                                    image: currentImage,
                                    fit: BoxFit.cover,
                                  );
                                }
                                if (widget.playlist.imageUrl.isNotEmpty) {
                                  return Image.network(
                                    widget.playlist.imageUrl,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return Container(
                                  color: Colors.black12,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 32,
                                    color: Colors.black54,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.cookbooksPublicLabel),
                      subtitle: Text(l10n.cookbooksPublicSubtitle),
                      value: _isPublic,
                      onChanged: _saving
                          ? null
                          : (value) {
                              setState(() {
                                _isPublic = value;
                                if (!value) _categoryError = null;
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.cookbooksCategoriesTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isPublic
                          ? l10n.cookbooksCategoriesPublicHint
                          : l10n.cookbooksCategoriesPrivateHint,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.cookbooksCategoriesSelected(_categories.length),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...kRecipeCategoryOptions.map((category) {
                          final key = category.key;
                          final selected = _categories.contains(key);
                          final atLimit = _atCategoryLimit && !selected;
                          return FilterChip(
                            label: Text(category.title),
                            selected: selected,
                            onSelected: _saving
                                ? null
                                : (value) {
                                    if (value && atLimit) {
                                      _categoryError =
                                          l10n.cookbooksCategoryLimit;
                                      setState(() {});
                                      return;
                                    }
                                    _toggleCategory(key, value);
                                  },
                          );
                        }),
                      ],
                    ),
                    if (_categoryError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _categoryError!,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.save),
                      label: Text(l10n.cookbooksSaveChanges),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/playlist/application/playlist_firestore_service.dart';
import 'package:foodiy/features/playlist/application/cookbook_firestore_service.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_share_helper.dart';
import 'package:foodiy/features/playlist/domain/personal_playlist_models.dart';
import 'package:foodiy/features/playlist/presentation/screens/personal_playlist_details_screen.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/shared/constants/categories.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class MyPlaylistsScreen extends StatefulWidget {
  const MyPlaylistsScreen({super.key});

  @override
  State<MyPlaylistsScreen> createState() => _MyPlaylistsScreenState();
}

class _MyPlaylistsScreenState extends State<MyPlaylistsScreen> {
  final _service = PersonalPlaylistService.instance;
  final _remote = PlaylistFirestoreService.instance;
  final _picker = ImagePicker();
  final _random = Random();
  final List<String> _placeholderImages = const [
    'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
  ];

  bool _initializing = true;
  List<PersonalPlaylist> _remoteCookbooks = const [];
  PersonalPlaylist? _favorites;
  String? _loadError;
  Map<String, String> _sourceById = const {};

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final favorites = _service.favoritesPlaylist;
    List<PersonalPlaylist> remote = const [];
    String? error;
    try {
      await CookbookFirestoreService.instance.ensureFavoritesCookbook(
        ownerId: uid,
      );
      remote = await _remote.fetchUserCookbooks(ownerId: uid);
      debugPrint(
        '[COOKBOOKS_SCREEN] ownerId=$uid fetchedFirestoreCookbooks=${remote.length}',
      );
    } catch (e, st) {
      final msg = e.toString();
      final urlMatch = RegExp(r'https://console\\.firebase\\.google\\.com[^\\s]+')
          .firstMatch(msg);
      final indexUrl = urlMatch?.group(0) ?? '';
      debugPrint(
        '[COOKBOOKS_FIRESTORE_ERROR] $msg createIndexUrl=$indexUrl\n$st',
      );
      error = 'load_error';
    }
    debugPrint(
      '[COOKBOOKS_SCREEN] localPlaylists=${favorites == null ? 0 : 1} firestoreCookbooks=${remote.length}',
    );
    final filteredRemote = _dedupeRemote(remote);
    for (final pl in filteredRemote) {
      _service.addOrUpdateFromRemote(pl);
    }
    final merged = _mergePlaylists(
      local: favorites == null ? const [] : [favorites],
      remote: filteredRemote,
      currentUid: uid,
    );
    setState(() {
      _favorites = favorites;
      _remoteCookbooks = filteredRemote;
      _initializing = false;
      _loadError = error;
    });
    debugPrint(
      '[COOKBOOKS_SCREEN] local=${favorites == null ? 0 : 1} firestore=${filteredRemote.length} total=${merged.length}',
    );
  }

  List<PersonalPlaylist> _dedupeRemote(List<PersonalPlaylist> remote) {
    final seenIds = <String>{};
    final seenNames = <String>{};
    final result = <PersonalPlaylist>[];
    for (final pl in remote) {
      final nameLower = pl.name.toLowerCase();
      if (nameLower == 'my chef recipes' ||
          pl.id == PlaylistFirestoreService.chefPlaylistId) {
        continue;
      }
      if (seenIds.contains(pl.id) || seenNames.contains(nameLower)) {
        continue;
      }
      seenIds.add(pl.id);
      seenNames.add(nameLower);
      result.add(pl);
    }
    return result;
  }

  List<PersonalPlaylist> _mergePlaylists({
    required List<PersonalPlaylist> local,
    required List<PersonalPlaylist> remote,
    required String currentUid,
  }) {
    final favId = PersonalPlaylistService.favoritesCookbookId(currentUid);
    final byId = <String, PersonalPlaylist>{};
    int legacyFavs = 0;
    for (final pl in [...remote, ...local]) {
      if (pl.id.isEmpty) continue;
      final isLegacyFav = pl.id != favId &&
          ((pl.name.toLowerCase() == 'favorite recipes') || pl.isFavoritesCookbook);
      if (pl.id == favId) {
        byId[pl.id] = pl.copyWith(id: favId, isFavorites: true);
        continue;
      }
      if (isLegacyFav) {
        legacyFavs++;
        continue;
      }
      byId.putIfAbsent(pl.id, () => pl);
    }
    byId.putIfAbsent(
      favId,
      () => PersonalPlaylist.favoritesPlaceholder(currentUid),
    );
    final mergedList = byId.values.toList();
    PersonalPlaylist? fav;
    final rest = <PersonalPlaylist>[];
    for (final pl in mergedList) {
      if (pl.id == favId && fav == null) {
        fav = pl.copyWith(id: favId, isFavorites: true);
        continue;
      }
      rest.add(pl);
    }
    rest.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    final result = fav != null ? [fav, ...rest] : rest;
    final restFirst = rest.isNotEmpty ? rest.first.id : '';
    final restFirstDate = rest.isNotEmpty
        ? (rest.first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        : null;
    debugPrint(
      '[COOKBOOKS_MERGE] local=${local.length} firestore=${remote.length} afterDedup=${result.length} favoritesSource=${fav != null ? 'merged' : ''} legacyFavoritesFiltered=$legacyFavs',
    );
    debugPrint(
      '[COOKBOOKS_ORDER] favorites=${fav?.id ?? ''} restFirst=$restFirst restFirstCreatedAt=$restFirstDate',
    );
    _sourceById = {
      for (final key in byId.keys) if (result.any((p) => p.id == key)) key: 'merged'
    };
    return result;
  }

  bool _isFavoritesCookbook(PersonalPlaylist cb, String currentUid) {
    final lower = cb.name.toLowerCase().trim();
    final favId = PersonalPlaylistService.favoritesCookbookId(currentUid);
    return cb.id == favId ||
        cb.isFavorites ||
        (lower == 'favorite recipes' && cb.ownerId == currentUid);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playlists = _mergePlaylists(
      local: _favorites == null ? const [] : [_favorites!],
      remote: _remoteCookbooks,
      currentUid: FirebaseAuth.instance.currentUser?.uid ?? '',
    );
    for (final cb in playlists) {
      final source = _sourceById[cb.id] ?? 'unknown';
      debugPrint(
        '[COOKBOOK_ITEM] source=$source id=${cb.id} name=${cb.name} ownerId=${cb.ownerId} isPublic=${cb.isPublic} createdAt=${cb.createdAt}',
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeMyCookbooks)),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 64),
                        const SizedBox(height: 12),
                        Text(l10n.cookbooksLoadError),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadPlaylists,
                          child: Text(l10n.tryAgain),
                        ),
                      ],
                    ),
                  ),
                )
              : playlists.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.menu_book, size: 64),
                            const SizedBox(height: 12),
                            Text(l10n.cookbooksEmptyTitle),
                            const SizedBox(height: 4),
                            Text(l10n.cookbooksEmptyBody),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: playlists.length,
                              itemBuilder: (context, index) {
                                final pl = playlists[index];
                                final title = (pl.name).trim().isNotEmpty
                                    ? pl.name
                                    : l10n.cookbooksUntitled;
                                final entries = _service.getEntries(pl.id);
                                final recipeCount = pl.recipeIds.isNotEmpty
                                    ? pl.recipeIds.length
                                    : entries.length;
                                debugPrint(
                                  '[COOKBOOK_CARD] id=${pl.id} recipeIds=${pl.recipeIds.length} entries=${entries.length}',
                                );
                                final isPublic = pl.isPublic;
                                final currentUid =
                                    FirebaseAuth.instance.currentUser?.uid ?? '';
                                final isFavorite =
                                    pl.ownerId == currentUid &&
                                    pl.name.toLowerCase() == 'favorite recipes';
                                final cardColor = isFavorite
                                    ? null
                                    : (isPublic ? Colors.green.shade50 : Colors.white);
                                final borderColor = isFavorite
                                    ? Colors.transparent
                                    : (isPublic
                                          ? Colors.green.shade300
                                          : Colors.grey.shade300);
                                final statusChip = Chip(
                                  avatar: Icon(
                                    isPublic ? Icons.public : Icons.lock,
                                    size: 16,
                                    color: isPublic
                                        ? Colors.green.shade800
                                        : Colors.grey.shade700,
                                  ),
                                  label: Text(
                                    isPublic
                                        ? l10n.discoverPublicBadge
                                        : l10n.cookbooksPrivateBadge,
                                  ),
                                  backgroundColor: isPublic
                                      ? Colors.green.shade100
                                      : Colors.grey.shade200,
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                );
                                return Card(
                                  color: cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: borderColor),
                                  ),
                                  child: Container(
                                    decoration: isFavorite
                                        ? BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.purple.shade100,
                                                Colors.blue.shade100,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          )
                                        : null,
                                    child: ListTile(
                                      leading: isFavorite
                                          ? Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color: Colors.pink.shade100,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.favorite,
                                                color: Colors.pink,
                                                size: 28,
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: pl.imageUrl.isNotEmpty
                                                  ? Image.network(
                                                      pl.imageUrl,
                                                      width: 56,
                                                      height: 56,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (context, error, stack) {
                                                        return Container(
                                                          width: 56,
                                                          height: 56,
                                                          color: Colors.grey.shade200,
                                                          alignment: Alignment.center,
                                                          child: const Icon(
                                                            Icons.menu_book,
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Container(
                                                      width: 56,
                                                      height: 56,
                                                      color: Colors.grey.shade200,
                                                      alignment: Alignment.center,
                                                      child: const Icon(Icons.menu_book),
                                                    ),
                                            ),
                                      title: Text(title),
                                      subtitle: Text(
                                        pl.isChefPlaylist
                                            ? '${l10n.cookbooksRecipeCount(recipeCount)} • ${l10n.cookbooksChefCookbookSuffix}'
                                            : l10n.cookbooksRecipeCount(recipeCount),
                                      ),
                                      trailing: isFavorite
                                          ? statusChip
                                          : Wrap(
                                              spacing: 8,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                statusChip,
                                                PopupMenuButton<_PlaylistAction>(
                                                  onSelected: (action) {
                                                    switch (action) {
                                                      case _PlaylistAction.rename:
                                                        _onRenamePlaylist(pl);
                                                        break;
                                                      case _PlaylistAction.delete:
                                                        _onDeletePlaylist(pl);
                                                        break;
                                                      case _PlaylistAction.share:
                                                        _onSharePlaylist(pl);
                                                        break;
                                                    }
                                                  },
                                                  itemBuilder: (context) {
                                                    final items =
                                                        <
                                                          PopupMenuEntry<_PlaylistAction>
                                                        >[];
                                                    items.add(
                                                      PopupMenuItem(
                                                        value: _PlaylistAction.rename,
                                                        child: Text(l10n.cookbooksActionRename),
                                                      ),
                                                    );
                                                    items.add(
                                                      PopupMenuItem(
                                                        value: _PlaylistAction.share,
                                                        child: Text(l10n.cookbooksActionShare),
                                                      ),
                                                    );
                                                    items.add(
                                                      PopupMenuItem(
                                                        value: _PlaylistAction.delete,
                                                        child: Text(l10n.cookbooksActionDelete),
                                                      ),
                                                    );
                                                    return items;
                                                  },
                                                ),
                                              ],
                                            ),
                                      onTap: () async {
                                        final exists = _service.playlists.any(
                                          (p) => p.id == pl.id,
                                        );
                                        if (!exists) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                l10n.cookbooksMissing,
                                              ),
                                            ),
                                          );
                                          setState(() {});
                                          return;
                                        }
                                        await context.push(
                                          AppRoutes.myPlaylistsDetails,
                                          extra: PersonalPlaylistDetailsArgs(
                                            playlistId: pl.id,
                                          ),
                                        );
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreatePlaylistPressed,
        child: const Icon(Icons.add),
        heroTag: 'playlists-fab',
      ),
    );
  }

  Future<void> _onCreatePlaylistPressed() async {
    final l10n = AppLocalizations.of(context)!;
    final draft = await Navigator.of(context).push<_CookbookDraft>(
      MaterialPageRoute(
        builder: (_) => _CreateCookbookWizard(
          picker: _picker,
          placeholderImages: _placeholderImages,
        ),
        fullscreenDialog: true,
      ),
    );
    if (draft == null) return;

    final fallbackImage =
        _placeholderImages[_random.nextInt(_placeholderImages.length)];
    final imageUrl = (draft.imagePath ?? '').isNotEmpty
        ? draft.imagePath!
        : fallbackImage;

    try {
      _service.createPlaylist(
        draft.name,
        isPublic: draft.isPublic,
        imageUrl: imageUrl,
        categories: draft.categories,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cookbooksCreateFailed('${e.toString()}'))),
        );
      }
      return;
    }
    setState(() {});
    unawaited(_loadPlaylists());
  }

  Future<void> _onRenamePlaylist(PersonalPlaylist playlist) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: playlist.name);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.cookbooksRenameTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: l10n.cookbooksRenameNewName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.homeCancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.cookbooksNameRequired)),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: Text(l10n.cookbooksSave),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _service.renamePlaylist(playlist.id, controller.text.trim());
      setState(() {});
    }
  }

  Future<void> _onDeletePlaylist(PersonalPlaylist playlist) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.cookbooksDeleteTitle),
          content: Text(l10n.cookbooksDeleteMessage(playlist.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.homeCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.homeDelete),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      var localDeleted = false;
      var remoteDeleted = false;
      try {
        localDeleted = _service.removePlaylist(playlist.id);
        await _remote.deleteCookbook(playlist.id);
        remoteDeleted = true;
      } catch (e) {
        debugPrint('[COOKBOOK_DELETE] id=${playlist.id} localDeleted=$localDeleted firestoreDeleted=$remoteDeleted error=$e');
      }
      debugPrint(
        '[COOKBOOK_DELETE] id=${playlist.id} localDeleted=$localDeleted firestoreDeleted=$remoteDeleted',
      );
      setState(() {});
      unawaited(_loadPlaylists());
    }
  }

  void _onSharePlaylist(PersonalPlaylist playlist) {
    final l10n = AppLocalizations.of(context)!;
    final text = PersonalPlaylistShareHelper.formatPlaylist(playlist, _service);
    Share.share(text, subject: l10n.cookbooksShareSubject(playlist.name));
  }
}

class _CookbookDraft {
  _CookbookDraft({
    required this.name,
    required this.isPublic,
    required this.categories,
    this.imagePath,
  });

  final String name;
  final bool isPublic;
  final List<String> categories;
  final String? imagePath;
}

class _CreateCookbookWizard extends StatefulWidget {
  const _CreateCookbookWizard({
    required this.picker,
    required this.placeholderImages,
  });

  final ImagePicker picker;
  final List<String> placeholderImages;

  @override
  State<_CreateCookbookWizard> createState() => _CreateCookbookWizardState();
}

class _CreateCookbookWizardState extends State<_CreateCookbookWizard> {
  final _nameController = TextEditingController();
  int _step = 0;
  bool _isPublic = true;
  String? _pickedImagePath;
  final _selectedCategories = <String>{};
  String? _nameError;
  String? _categoryError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _atCategoryLimit => _selectedCategories.length >= 5;

  void _pickImage() async {
    final picked = await widget.picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() => _pickedImagePath = picked.path);
    }
  }

  void _next() {
    if (_step == 0) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        setState(() => _nameError = 'Name is required');
        return;
      }
      setState(() {
        _nameError = null;
        _step = 1;
      });
      return;
    }
    _submit();
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step -= 1);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _toggleCategory(String category, bool selected) {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      if (selected) {
        if (_selectedCategories.contains(category)) return;
        if (_atCategoryLimit) {
          _categoryError = l10n.cookbooksCategoryLimit;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cookbooksCategoryLimit)),
          );
          return;
        }
        _selectedCategories.add(category);
      } else {
        _selectedCategories.remove(category);
      }
      _categoryError = null;
    });
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    if (_isPublic && _selectedCategories.isEmpty) {
      setState(
        () => _categoryError = l10n.cookbooksCategoryPublicRequired,
      );
      return;
    }
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l10n.cookbooksNameRequired);
      return;
    }
    Navigator.of(context).pop(
      _CookbookDraft(
        name: name,
        isPublic: _isPublic,
        categories: _selectedCategories.toList(growable: false),
        imagePath: _pickedImagePath,
      ),
    );
  }

  Widget _buildStepContent() {
    final l10n = AppLocalizations.of(context)!;
    if (_step == 0) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.cookbooksBasicsTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.cookbooksNameLabel,
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _pickedImagePath != null
                      ? Image.file(
                          File(_pickedImagePath!),
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 72,
                          height: 72,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_outlined),
                        ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n.cookbooksChooseImage),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.discoverPublicBadge),
              subtitle: Text(l10n.cookbooksPublicSubtitle),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                  if (!_isPublic) {
                    _categoryError = null;
                  }
                });
              },
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cookbooksCategoriesTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _isPublic
                ? l10n.cookbooksCategoriesPublicHint
                : l10n.cookbooksCategoriesPrivateHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.cookbooksCategoriesSelected(_selectedCategories.length),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...kRecipeCategoryOptions.map((category) {
                final key = category.key;
                final selected = _selectedCategories.contains(key);
                final atLimit = _atCategoryLimit && !selected;
                return FilterChip(
                  label: Text(category.title),
                  selected: selected,
                  onSelected: (value) {
                    if (value && atLimit) {
                      _toggleCategory(key, value);
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
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cookbooksCreateTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(child: _buildStepContent()),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_step > 0)
                OutlinedButton(onPressed: _back, child: Text(l10n.cookbooksBack)),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_step == 0 ? l10n.cookbooksNext : l10n.cookbooksCreate),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PlaylistAction { rename, delete, share }

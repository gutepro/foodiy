import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/access_control_service.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/features/playlist/application/playlist_firestore_service.dart';
import 'package:foodiy/features/playlist/application/cookbook_firestore_service.dart';
import '../domain/personal_playlist_models.dart';
import 'package:foodiy/shared/constants/categories.dart';

class PersonalPlaylistService {
  PersonalPlaylistService._internal();

  static final PersonalPlaylistService _instance =
      PersonalPlaylistService._internal();
  static PersonalPlaylistService get instance => _instance;
  static String favoritesCookbookId(String uid) => 'favorites_$uid';

  final _uuid = const Uuid();
  final List<PersonalPlaylist> _playlists = [];
  PersonalPlaylist? _chefPlaylist;
  PersonalPlaylist? _favoritesPlaylist;
  static const _storageKey = 'personal_playlists_v1';
  final PlaylistFirestoreService _remote = PlaylistFirestoreService.instance;
  String get _uid =>
      CurrentUserService.instance.currentProfile?.uid ??
      FirebaseAuth.instance.currentUser?.uid ??
      '';

  String get _ownerDisplayName =>
      CurrentUserService.instance.currentProfile?.displayName ?? '';

  List<PersonalPlaylist> get playlists => List.unmodifiable(_playlists);
  PersonalPlaylist? get favoritesPlaylist => _favoritesPlaylist;

  List<String> _normalizeCategories(List<String> categories) {
    final result = <String>[];
    final seen = <String>{};
    for (final category in categories) {
      final trimmed = categoryKeyFromInput(category);
      if (trimmed.isEmpty || seen.contains(trimmed)) continue;
      result.add(trimmed);
      seen.add(trimmed);
      if (result.length >= 5) break;
    }
    return result;
  }

  String _normalizeForSearch(String input) =>
      input.trim().toLowerCase().replaceAll(RegExp(r'\\s+'), ' ');

  bool _isFavoritesPlaylist(PersonalPlaylist p) {
    final lower = p.name.toLowerCase().trim();
    final favId = favoritesCookbookId(_uid);
    return p.id == favId ||
        p.isFavorites ||
        (lower == 'favorite recipes' && p.ownerId == _uid);
  }

  void _purgeLocalFavorites() {
    final before = _playlists.length;
    _playlists.removeWhere(_isFavoritesPlaylist);
    if (_playlists.length != before) {
      unawaited(_saveToStorage());
    }
    _favoritesPlaylist = null;
  }

  Future<void> reset() async {
    _playlists.clear();
    _chefPlaylist = null;
    _favoritesPlaylist = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) {
      // Ensure favorites exists for first-time users.
      ensureFavoritesPlaylist();
      unawaited(_cleanupChefCookbooksRemote());
      return;
    }
    try {
      final data = json.decode(jsonString) as List<dynamic>;
    _playlists
      ..clear()
      ..addAll(
        data.map((e) => PersonalPlaylist.fromJson(e as Map<String, dynamic>)),
      );
      _purgeLocalFavorites();
      final removedChef = _removeChefPlaylists();
      if (removedChef) {
        await _saveToStorage();
      }
      debugPrint(
        '[PLAYLIST_CLEANUP] removedMyChefRecipes=${removedChef ? 'true' : 'false'}',
      );
      _ensureFavoritesId();
      final chefPlaylists = _playlists
          .where((p) => p.isChefPlaylist)
          .toList(growable: false);
      _chefPlaylist = chefPlaylists.isNotEmpty ? chefPlaylists.first : null;
      _favoritesPlaylist = _playlists.firstWhere(
        (p) => p.id == favoritesCookbookId(_uid),
        orElse: () => PersonalPlaylist(id: '', name: ''),
      );
      if (_favoritesPlaylist?.id.isEmpty == true) {
        _favoritesPlaylist = null;
      }
      unawaited(_cleanupChefCookbooksRemote());
      debugPrint(
        'PersonalPlaylistService: loaded ${_playlists.length} playlists from storage',
      );
    } catch (e) {
      debugPrint(
        'PersonalPlaylistService: failed to load playlists from storage: $e',
      );
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _playlists.map((p) => p.toJson()).toList();
      final jsonString = json.encode(data);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('PersonalPlaylistService: failed to save playlists: $e');
    }
  }

  bool _removeChefPlaylists() {
    final initial = _playlists.length;
    _playlists.removeWhere(
      (p) =>
          p.name.toLowerCase() == 'my chef recipes' ||
          p.id == PlaylistFirestoreService.chefPlaylistId ||
          p.isChefPlaylist,
    );
    return _playlists.length != initial;
  }

  Future<void> _cleanupChefCookbooksRemote() async {
    final uid = _uid;
    if (uid.isEmpty) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('cookbooks')
          .where('ownerId', isEqualTo: uid)
          .get();
      if (snap.docs.isEmpty) {
        debugPrint('[COOKBOOK_CLEANUP_FIRESTORE] deletedCount=0');
        return;
      }
      var batch = FirebaseFirestore.instance.batch();
      var count = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final name = (data['title'] ?? data['name'] ?? '').toString();
        final lower = name.toLowerCase();
        if (lower == 'my chef recipes' || doc.id == PlaylistFirestoreService.chefPlaylistId) {
          batch.delete(doc.reference);
          count++;
        }
        if (count > 0 && count % 400 == 0) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
        }
      }
      if (count > 0) {
        await batch.commit();
      }
      debugPrint('[COOKBOOK_CLEANUP_FIRESTORE] deletedCount=$count');
    } catch (e, st) {
      debugPrint('[COOKBOOK_CLEANUP_FIRESTORE] error=$e\n$st');
    }
  }

  void _ensureFavoritesId() {
    final favId = favoritesCookbookId(_uid);
    final idx = _playlists.indexWhere(
      (p) => p.name.toLowerCase() == 'favorite recipes',
    );
    if (idx == -1) return;
    final existing = _playlists[idx];
    if (existing.id == favId && existing.ownerId == _uid) return;
    final migrated = PersonalPlaylist(
      id: favId,
      name: existing.name,
      imageUrl: existing.imageUrl,
      entries: List<PersonalPlaylistEntry>.from(existing.entries),
      ownerId: _uid,
      isPublic: false,
      isChefPlaylist: false,
      isFavorites: true,
      categories: existing.categories,
    );
    _playlists[idx] = migrated;
    _favoritesPlaylist = migrated;
    unawaited(_saveToStorage());
  }

  PersonalPlaylist createPlaylist(
    String name, {
    bool isPublic = false,
    String imageUrl = '',
    List<String> categories = const [],
  }) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final normalizedCategories = _normalizeCategories(categories);
    if (isPublic && normalizedCategories.isEmpty) {
      throw ArgumentError('Public cookbooks require at least one category');
    }
    final normalizedName = _normalizeForSearch(name).isNotEmpty
        ? name.trim()
        : 'Untitled cookbook';
    final playlist = PersonalPlaylist(
      id: _uuid.v4(),
      name: normalizedName,
      imageUrl: imageUrl,
      ownerId: uid,
      isPublic: isPublic,
      categories: normalizedCategories,
    );
    _playlists.insert(0, playlist);
    if (playlist.name.toLowerCase() == 'favorite recipes') {
      _favoritesPlaylist = playlist;
    }
    debugPrint('PersonalPlaylistService: created playlist "${playlist.name}"');
    unawaited(_saveToStorage());
    unawaited(
      PlaylistFirestoreService.instance.saveCookbook(
        playlist,
        ownerName: _ownerDisplayName,
      ),
    );
    return playlist;
  }

  PersonalPlaylist getOrCreateChefPlaylist() {
    throw StateError('Chef playlist is no longer supported');
  }

  PersonalPlaylist ensureFavoritesPlaylist({String placeholderImage = ''}) {
    if (_favoritesPlaylist != null) {
      return _favoritesPlaylist!;
    }
    final favId = favoritesCookbookId(_uid);
    final playlist = PersonalPlaylist(
      id: favId,
      name: 'Favorite recipes',
      imageUrl: placeholderImage,
      ownerId: _uid,
      isPublic: false,
      isChefPlaylist: false,
      isFavorites: true,
    );
    _playlists.insert(0, playlist);
    _favoritesPlaylist = playlist;
    unawaited(_saveToStorage());
    unawaited(
      PlaylistFirestoreService.instance.saveCookbook(
        playlist,
        ownerName: _ownerDisplayName,
      ),
    );
    return playlist;
  }

  void renamePlaylist(String id, String newName) {
    if (_favoritesPlaylist != null && _favoritesPlaylist!.id == id) {
      debugPrint(
        'PersonalPlaylistService: favorite playlist cannot be renamed',
      );
      return;
    }
    final idx = _playlists.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final pl = _playlists[idx];
    final updated = pl.copyWith(name: newName);
    _playlists[idx] = updated;
    unawaited(_saveToStorage());
    unawaited(
      _remote.updateCookbook(
        cookbookId: id,
        title: newName,
        coverImageUrl: updated.imageUrl,
        categories: updated.categories,
        isPublic: updated.isPublic,
        ownerId: updated.ownerId,
        ownerName: _ownerDisplayName,
      ),
    );
  }

  bool removePlaylist(String id) {
    if (_favoritesPlaylist != null && _favoritesPlaylist!.id == id) {
      debugPrint(
        'PersonalPlaylistService: favorite playlist cannot be removed',
      );
      return false;
    }
    final before = _playlists.length;
    _playlists.removeWhere((p) => p.id == id);
    final removed = _playlists.length < before;
    unawaited(_saveToStorage());
    return removed;
  }

  Future<void> updateCookbook({
    required String id,
    required String name,
    required bool isPublic,
    required String imageUrl,
    List<String>? categories,
  }) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index == -1) return;
    final current = _playlists[index];
    final normalizedCategories = _normalizeCategories(
      categories ?? current.categories,
    );
    if (isPublic && normalizedCategories.isEmpty) {
      throw ArgumentError('Public cookbooks require at least one category');
    }
    final updated = current.copyWith(
      name: name,
      imageUrl: imageUrl,
      isPublic: isPublic,
      categories: normalizedCategories,
      createdAt: current.createdAt,
    );
    _playlists[index] = updated;
    unawaited(_saveToStorage());
    await _remote.updateCookbook(
      cookbookId: id,
      title: updated.name,
      coverImageUrl: updated.imageUrl,
      categories: normalizedCategories,
      isPublic: isPublic,
      ownerId: updated.ownerId,
      ownerName: _ownerDisplayName,
    );
  }

  bool tryRemovePlaylistById(String id) {
    if (_favoritesPlaylist != null && _favoritesPlaylist!.id == id) {
      debugPrint(
        'PersonalPlaylistService: favorite playlist cannot be removed',
      );
      return false;
    }
    final before = _playlists.length;
    _playlists.removeWhere((p) => p.id == id);
    final removed = _playlists.length < before;
    if (removed) {
      unawaited(_saveToStorage());
    }
    return removed;
  }

  List<PersonalPlaylist> getCurrentUserPlaylists() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return List.unmodifiable(_playlists);
    return _playlists
        .where((p) => p.ownerId == uid || p.ownerId.isEmpty)
        .toList(growable: false);
  }

  List<PersonalPlaylistEntry> getEntries(String playlistId) {
    final pl = _playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => PersonalPlaylist(id: playlistId, name: 'Unknown'),
    );
    return List.unmodifiable(pl.entries);
  }

  void addEntry(String playlistId, PersonalPlaylistEntry entry) {
    unawaited(addEntryAwaitAttach(playlistId, entry));
  }

  Future<void> addEntryAwaitAttach(
    String playlistId,
    PersonalPlaylistEntry entry,
  ) async {
    debugPrint(
      '[ADD_TO_COOKBOOK_SERVICE] addEntryAwaitAttach start playlistId=$playlistId recipeId=${entry.recipeId}',
    );
    final pl = _playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => PersonalPlaylist(id: playlistId, name: 'Unknown'),
    );
    final exists = pl.entries.any((e) => e.recipeId == entry.recipeId);
    if (!exists) {
      pl.entries.add(entry);
      if (!pl.recipeIds.contains(entry.recipeId)) {
        pl.recipeIds.add(entry.recipeId);
      }
    }
    debugPrint(
      'PersonalPlaylistService: playlist "${pl.name}" now has ${pl.entries.length} entries',
    );
    unawaited(_saveToStorage());
    await CookbookFirestoreService.instance.addRecipeToCookbook(
      cookbookId: playlistId,
      recipeId: entry.recipeId,
      ownerId: pl.ownerId.isNotEmpty ? pl.ownerId : _uid,
      title: pl.name,
      isPublic: pl.isPublic,
      coverImageUrl: pl.imageUrl,
    );
    debugPrint(
      '[ADD_TO_COOKBOOK_SERVICE] addEntryAwaitAttach success playlistId=$playlistId recipeId=${entry.recipeId}',
    );
  }

  void addToChefPlaylist(PersonalPlaylistEntry entry) {
    debugPrint(
      'PersonalPlaylistService: addToChefPlaylist skipped (chef playlist removed)',
    );
  }

  void addOrUpdateFromRemote(
    PersonalPlaylist playlist, {
    bool persist = false,
  }) {
    if (playlist.name.toLowerCase() == 'my chef recipes' ||
        playlist.id == PlaylistFirestoreService.chefPlaylistId ||
        playlist.isChefPlaylist) {
      return;
    }
    if (_isFavoritesPlaylist(playlist)) {
      _playlists.removeWhere(_isFavoritesPlaylist);
      if (playlist.ownerId != _uid) {
        debugPrint(
          '[FAVORITES_GUARD] ignoring remote favorites for different owner id=${playlist.id} owner=${playlist.ownerId} current=$_uid',
        );
        return;
      }
      _favoritesPlaylist = PersonalPlaylist(
        id: favoritesCookbookId(_uid),
        name: 'Favorite recipes',
        imageUrl: playlist.imageUrl,
        entries: List<PersonalPlaylistEntry>.from(playlist.entries),
        recipeIds: List<String>.from(playlist.recipeIds),
        ownerId: _uid,
        isPublic: false,
        isChefPlaylist: false,
        isFavorites: true,
        categories: playlist.categories,
        createdAt: playlist.createdAt,
      );
      _playlists.add(_favoritesPlaylist!);
      if (persist) {
        unawaited(_saveToStorage());
      }
      return;
    }
    final idx = _playlists.indexWhere((p) => p.id == playlist.id);
    if (idx == -1) {
      _playlists.add(playlist);
    } else {
      _playlists[idx] = _playlists[idx].copyWith(
        name: playlist.name,
        imageUrl: playlist.imageUrl,
        recipeIds: List<String>.from(playlist.recipeIds),
        ownerId: playlist.ownerId,
        isPublic: playlist.isPublic,
        categories: playlist.categories,
        isChefPlaylist: false,
        createdAt: playlist.createdAt,
      );
    }
    if (persist) {
      unawaited(_saveToStorage());
    }
  }

  void removeEntry(String playlistId, String recipeId) {
    final pl = _playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => PersonalPlaylist(id: playlistId, name: 'Unknown'),
    );
    _removeEntries(pl, recipeId);
  }

  void removeRecipeEverywhere(String recipeId) {
    if (recipeId.isEmpty) return;
    for (final playlist in _playlists) {
      _removeEntries(playlist, recipeId);
    }
  }

  void _removeEntries(PersonalPlaylist playlist, String recipeId) {
    final before = playlist.entries.length;
    playlist.entries.removeWhere((e) => e.recipeId == recipeId);
    if (before != playlist.entries.length) {
      unawaited(_saveToStorage());
      unawaited(
        PlaylistFirestoreService.instance.syncCookbookEntries(
          playlist,
          ownerName: _ownerDisplayName,
        ),
      );
    }
  }

  // TODO: Persist playlists per user in Firestore.
}

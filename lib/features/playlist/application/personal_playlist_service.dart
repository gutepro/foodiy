import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/access_control_service.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import '../domain/personal_playlist_models.dart';

class PersonalPlaylistService {
  PersonalPlaylistService._internal();

  static final PersonalPlaylistService _instance =
      PersonalPlaylistService._internal();
  static PersonalPlaylistService get instance => _instance;

  final _uuid = const Uuid();
  final List<PersonalPlaylist> _playlists = [];
  PersonalPlaylist? _chefPlaylist;
  PersonalPlaylist? _favoritesPlaylist;
  static const _storageKey = 'personal_playlists_v1';

  List<PersonalPlaylist> get playlists => List.unmodifiable(_playlists);
  PersonalPlaylist? get favoritesPlaylist => _favoritesPlaylist;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return;
    try {
      final data = json.decode(jsonString) as List<dynamic>;
      _playlists
        ..clear()
        ..addAll(
          data.map((e) => PersonalPlaylist.fromJson(e as Map<String, dynamic>)),
        );
      final chefPlaylists =
          _playlists.where((p) => p.isChefPlaylist).toList(growable: false);
      _chefPlaylist = chefPlaylists.isNotEmpty ? chefPlaylists.first : null;
      _favoritesPlaylist = _playlists.firstWhere(
        (p) => p.name.toLowerCase() == 'favorite recipes',
        orElse: () => PersonalPlaylist(id: '', name: ''),
      );
      if (_favoritesPlaylist?.id.isEmpty == true) {
        _favoritesPlaylist = null;
      }
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

  PersonalPlaylist createPlaylist(
    String name, {
    bool isPublic = false,
    String imageUrl = '',
  }) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final playlist = PersonalPlaylist(
      id: _uuid.v4(),
      name: name,
      imageUrl: imageUrl,
      ownerId: uid,
      isPublic: isPublic,
    );
    _playlists.insert(0, playlist);
    if (playlist.name.toLowerCase() == 'favorite recipes') {
      _favoritesPlaylist = playlist;
    }
    debugPrint('PersonalPlaylistService: created playlist "${playlist.name}"');
    unawaited(_saveToStorage());
    return playlist;
  }

  PersonalPlaylist getOrCreateChefPlaylist() {
    if (_chefPlaylist != null) {
      return _chefPlaylist!;
    }
    final profile = CurrentUserService.instance.currentProfile;
    final userType = profile?.userType ?? UserType.freeUser;
    final access = AccessControlService.instance;

    if (!access.isChef(userType)) {
      throw StateError('Tried to create chef playlist for non chef user');
    }

    final playlist = PersonalPlaylist(
      id: _uuid.v4(),
      name: 'My chef recipes',
      ownerId: FirebaseAuth.instance.currentUser?.uid ?? '',
      isChefPlaylist: true,
    );
    _playlists.insert(0, playlist);
    _chefPlaylist = playlist;
    debugPrint(
      'PersonalPlaylistService: created chef playlist "${playlist.name}"',
    );
    unawaited(_saveToStorage());
    return playlist;
  }

  PersonalPlaylist ensureFavoritesPlaylist({
    String placeholderImage = '',
  }) {
    if (_favoritesPlaylist != null) {
      return _favoritesPlaylist!;
    }
    final created = createPlaylist(
      'Favorite recipes',
      isPublic: false,
      imageUrl: placeholderImage,
    );
    _favoritesPlaylist = created;
    return created;
  }

  void renamePlaylist(String id, String newName) {
    final pl = _playlists.firstWhere(
      (p) => p.id == id,
      orElse: () => PersonalPlaylist(id: id, name: 'Unknown'),
    );
    pl.name = newName;
    unawaited(_saveToStorage());
  }

  void removePlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
    unawaited(_saveToStorage());
  }

  Future<void> updateCookbook({
    required String id,
    required String name,
    required bool isPublic,
    required String imageUrl,
  }) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index == -1) return;
    final current = _playlists[index];
    final updated = PersonalPlaylist(
      id: current.id,
      name: name,
      imageUrl: imageUrl,
      entries: current.entries,
      ownerId: current.ownerId,
      isPublic: isPublic,
      isChefPlaylist: current.isChefPlaylist,
    );
    _playlists[index] = updated;
    unawaited(_saveToStorage());
  }

  bool tryRemovePlaylistById(String id) {
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
    final pl = _playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => PersonalPlaylist(id: playlistId, name: 'Unknown'),
    );
    final exists = pl.entries.any((e) => e.recipeId == entry.recipeId);
    if (!exists) {
      pl.entries.add(entry);
    }
    debugPrint(
      'PersonalPlaylistService: playlist "${pl.name}" now has ${pl.entries.length} entries',
    );
    unawaited(_saveToStorage());
  }

  void addToChefPlaylist(PersonalPlaylistEntry entry) {
    final playlist = getOrCreateChefPlaylist();
    addEntry(playlist.id, entry);
  }

  void removeEntry(String playlistId, String recipeId) {
    final pl = _playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => PersonalPlaylist(id: playlistId, name: 'Unknown'),
    );
    pl.entries.removeWhere((e) => e.recipeId == recipeId);
    unawaited(_saveToStorage());
  }

  // TODO: Persist playlists per user in Firestore.
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../domain/personal_playlist_models.dart';
import 'package:foodiy/shared/constants/categories.dart';
import 'personal_playlist_service.dart';
import 'cookbook_firestore_service.dart';

/// Firestore persistence for personal playlists (chef-focused for now).
class PlaylistFirestoreService {
  PlaylistFirestoreService._internal();

  static final PlaylistFirestoreService instance =
      PlaylistFirestoreService._internal();

  final _firestore = FirebaseFirestore.instance;
  static const String _playlistsCollection = 'playlists';
  static const String _cookbooksCollection = 'cookbooks';
  static const String chefPlaylistId = 'chef_recipes';

  Future<void> updateCookbook({
    required String cookbookId,
    required String title,
    required String coverImageUrl,
    required List<String> categories,
    required bool isPublic,
    String ownerName = '',
    String ownerId = '',
  }) async {
    final normalizedCategories = _normalizeCategories(categories);
    final docRef = _firestore.collection(_cookbooksCollection).doc(cookbookId);
    final normalizedTitle = title.isNotEmpty ? title : 'Untitled cookbook';
    await docRef.set({
      'title': normalizedTitle,
      'name': normalizedTitle,
      'coverImageUrl': coverImageUrl,
      'imageUrl': coverImageUrl,
      'nameLower': _normalizeForSearch(normalizedTitle),
      'isPublic': isPublic,
      'categories': normalizedCategories,
      'isPublic': isPublic,
      if (ownerName.isNotEmpty) 'ownerName': ownerName,
      if (ownerId.isNotEmpty) 'ownerId': ownerId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  List<String> _normalizeCategories(List<String> categories) {
    final seen = <String>{};
    final result = <String>[];
    for (final category in categories) {
      final key = categoryKeyFromInput(category);
      if (key.isEmpty || seen.contains(key)) continue;
      result.add(key);
      seen.add(key);
      if (result.length >= 5) break;
    }
    return result;
  }

  String _normalizeForSearch(String input) =>
      input.trim().toLowerCase().replaceAll(RegExp(r'\\s+'), ' ');

  DocumentReference<Map<String, dynamic>> _chefPlaylistDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection(_playlistsCollection)
        .doc(chefPlaylistId);
  }

  Future<PersonalPlaylist> ensureChefPlaylist(String uid) async {
    final docRef = _chefPlaylistDoc(uid);
    await docRef.set({
      'id': chefPlaylistId,
      'name': 'My chef recipes',
      'ownerId': uid,
      'isChefPlaylist': true,
      'isPublic': false,
      'imageUrl': '',
    }, SetOptions(merge: true));
    return PersonalPlaylist(
      id: chefPlaylistId,
      name: 'My chef recipes',
      ownerId: uid,
      isChefPlaylist: true,
      isPublic: false,
    );
  }

  Future<void> addEntryToChefPlaylist({
    required String uid,
    required PersonalPlaylistEntry entry,
  }) async {
    if (uid.isEmpty) return;
    try {
      final playlist = await ensureChefPlaylist(uid);
      final docRef = _chefPlaylistDoc(
        uid,
      ).collection('entries').doc(entry.recipeId);
      await docRef.set(entry.toJson());
      debugPrint(
        'PlaylistFirestoreService: added ${entry.recipeId} to chef playlist ${playlist.id}',
      );
    } catch (e) {
      debugPrint(
        'PlaylistFirestoreService: failed to add entry to chef playlist: $e',
      );
    }
  }

  Future<void> attachRecipeToCookbook({
    required String cookbookId,
    required PersonalPlaylistEntry entry,
  }) async {
    debugPrint(
      '[ADD_TO_COOKBOOK_FIRESTORE] start cookbookId=$cookbookId recipeId=${entry.recipeId}',
    );
    final docRef = _firestore.collection(_cookbooksCollection).doc(cookbookId);
    final entryRef = docRef.collection('entries').doc(entry.recipeId);
    final batch = _firestore.batch();
    batch.set(_firestore.collection('recipes').doc(entry.recipeId), {
      'isPublic': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(entryRef, {
      'recipeId': entry.recipeId,
      'title': entry.title,
      'imageUrl': entry.imageUrl,
      'time': entry.time,
      'difficulty': entry.difficulty,
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(docRef, {
      'updatedAt': FieldValue.serverTimestamp(),
      'recipeCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
    await batch.commit();
    debugPrint(
      '[ADD_TO_COOKBOOK_FIRESTORE] success cookbookId=$cookbookId recipeId=${entry.recipeId}',
    );
  }

  Future<void> saveCookbook(
    PersonalPlaylist playlist, {
    String ownerName = '',
  }) async {
    try {
      final categories = _normalizeCategories(playlist.categories);
      final title = playlist.name.trim();
      final normalizedTitle = title.isNotEmpty ? title : 'Untitled cookbook';
      final coverImageUrl = playlist.imageUrl.trim();
      final docRef = _firestore
          .collection(_cookbooksCollection)
          .doc(playlist.id);
      await docRef.set({
        'id': playlist.id,
        // Canonical cookbook schema (Discover + cross-user).
        'title': normalizedTitle,
        'coverImageUrl': coverImageUrl,
        'nameLower': _normalizeForSearch(normalizedTitle),
        'isFavorites': playlist.id.startsWith('favorites_') || playlist.isFavorites,

        // Backward-compatibility fields.
        'name': playlist.name,
        'ownerId': playlist.ownerId,
        'ownerName': ownerName,
        'isPublic': playlist.isPublic,
        'categories': categories,
        'imageUrl': playlist.imageUrl,
        'viewsCount': FieldValue.increment(0),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      // Write entries as subcollection for discover/profile detail usage.
      final batch = _firestore.batch();
      for (final e in playlist.entries) {
        final entryDoc = docRef.collection('entries').doc(e.recipeId);
        batch.set(entryDoc, e.toJson());
      }
      await batch.commit();
    } catch (e) {
      debugPrint('PlaylistFirestoreService: saveCookbook failed: $e');
    }
  }

  Future<void> syncCookbookEntries(
    PersonalPlaylist playlist, {
    String ownerName = '',
  }) async {
    try {
      final categories = _normalizeCategories(playlist.categories);
      final title = playlist.name.trim();
      final coverImageUrl = playlist.imageUrl.trim();
      final docRef = _firestore
          .collection(_cookbooksCollection)
          .doc(playlist.id);
      await docRef.set({
        'id': playlist.id,
        // Canonical cookbook schema (Discover + cross-user).
        'title': title.isNotEmpty ? title : 'Untitled cookbook',
        'coverImageUrl': coverImageUrl,
        'nameLower': _normalizeForSearch(title.isNotEmpty ? title : 'Untitled cookbook'),

        // Backward-compatibility fields.
        'name': playlist.name,
        'ownerId': playlist.ownerId,
        'ownerName': ownerName,
        'isPublic': playlist.isPublic,
        'categories': categories,
        'imageUrl': playlist.imageUrl,
        'viewsCount': FieldValue.increment(0),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      final batch = _firestore.batch();
      for (final e in playlist.entries) {
        final entryDoc = docRef.collection('entries').doc(e.recipeId);
        batch.set(entryDoc, e.toJson());
      }
      await batch.commit();
    } catch (e) {
      debugPrint('PlaylistFirestoreService: syncCookbookEntries failed: $e');
    }
  }

  Future<void> removeRecipeFromAllCookbooks(String recipeId) async {
    if (recipeId.isEmpty) return;
    try {
      final snapshot = await _firestore
          .collectionGroup('entries')
          .where('recipeId', isEqualTo: recipeId)
          .get();
      if (snapshot.docs.isEmpty) return;
      var batch = _firestore.batch();
      var operations = 0;
      Future<void> commitBatch() async {
        await batch.commit();
        batch = _firestore.batch();
        operations = 0;
      }

      for (final entry in snapshot.docs) {
        batch.delete(entry.reference);
        operations++;
        if (operations >= 400) {
          await commitBatch();
        }
      }
      if (operations > 0) {
        await batch.commit();
      }
      debugPrint(
        'PlaylistFirestoreService: removed recipe $recipeId from ${snapshot.docs.length} cookbook entries',
      );
    } catch (e, st) {
      debugPrint(
        'PlaylistFirestoreService: removeRecipeFromAllCookbooks failed: $e\n$st',
      );
    }
  }

  Future<List<PersonalPlaylist>> fetchUserCookbooks({
    required String ownerId,
    int limit = 50,
  }) async {
    if (ownerId.isEmpty) return const [];
    debugPrint(
      '[COOKBOOKS_QUERY] ownerId=$ownerId orderBy=updatedAt desc limit=$limit',
    );
    try {
      final snap = await _firestore
          .collection(_cookbooksCollection)
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();
      return snap.docs
          .map((doc) {
            final data = doc.data();
            return PersonalPlaylist(
              id: doc.id,
              name: (data['title'] ?? data['name'] ?? 'Cookbook').toString(),
              imageUrl: (data['coverImageUrl'] ?? data['imageUrl'] ?? '')
                  .toString(),
              ownerId: (data['ownerId'] ?? '').toString(),
              isPublic: (data['isPublic'] as bool?) ?? false,
              isFavorites: (data['isFavorites'] as bool?) ??
                  doc.id.startsWith('favorites_'),
              recipeIds: (data['recipeIds'] as List<dynamic>?)
                      ?.whereType<String>()
                      .toList() ??
                  const <String>[],
              categories:
                  (data['categories'] as List<dynamic>?)
                      ?.whereType<String>()
                      .toList() ??
                  const [],
              createdAt: (data['createdAt'] is Timestamp)
                  ? (data['createdAt'] as Timestamp).toDate()
                  : null,
            );
          })
          .toList(growable: false);
    } on FirebaseException catch (e, st) {
      if (e.code == 'failed-precondition' && e.message != null) {
        final match = RegExp(r'https://console\\.firebase\\.google\\.com[^\\s]+')
            .firstMatch(e.message!);
        final url = match?.group(0) ?? '';
        debugPrint('[COOKBOOKS_INDEX_URL] $url');
      }
      debugPrint('[COOKBOOKS_FIRESTORE_ERROR] $e\n$st');
      rethrow;
    }
  }

  Future<void> deleteCookbook(String cookbookId) async {
    if (cookbookId.isEmpty) return;
    await _firestore.collection(_cookbooksCollection).doc(cookbookId).delete();
  }
}

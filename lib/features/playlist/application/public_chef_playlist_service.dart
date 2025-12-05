import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../domain/public_chef_playlist_models.dart';

class PublicChefPlaylistService {
  PublicChefPlaylistService._internal();

  static final PublicChefPlaylistService _instance =
      PublicChefPlaylistService._internal();
  static PublicChefPlaylistService get instance => _instance;

  final _uuid = const Uuid();
  final _firestore = FirebaseFirestore.instance;
  static const _collectionName = 'public_chef_playlists';
  final List<PublicChefPlaylist> _playlists = [];

  List<PublicChefPlaylist> get playlists => List.unmodifiable(_playlists);

  Future<PublicChefPlaylist> createPlaylist({
    required String title,
    required String description,
    required List<PublicChefPlaylistEntry> entries,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final chefName = user?.displayName ?? (user?.email ?? 'Chef');
    final chefId = user?.uid;
    final docRef = _firestore.collection(_collectionName).doc();

    final playlist = PublicChefPlaylist(
      id: docRef.id,
      chefName: chefName,
      chefId: chefId,
      title: title,
      description: description,
      entries: entries,
    );

    await docRef.set(playlist.toJson());
    final batch = _firestore.batch();
    final entriesCollection = docRef.collection('entries');
    for (final e in entries) {
      final entryDoc = entriesCollection.doc(e.recipeId);
      batch.set(entryDoc, e.toJson());
    }
    await batch.commit();

    _playlists.insert(0, playlist);
    debugPrint(
      'PublicChefPlaylistService: created public playlist "${playlist.title}"',
    );

    return playlist;
  }

  Future<void> deletePlaylist(String id) async {
    final docRef = _firestore.collection(_collectionName).doc(id);
    final entriesSnap = await docRef.collection('entries').get();
    final batch = _firestore.batch();
    for (final entry in entriesSnap.docs) {
      batch.delete(entry.reference);
    }
    batch.delete(docRef);
    await batch.commit();
    _playlists.removeWhere((p) => p.id == id);
  }

  Future<void> loadFromFirestore() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      final List<PublicChefPlaylist> loaded = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final entriesSnap = await doc.reference.collection('entries').get();
        final entries = entriesSnap.docs
            .map((e) => PublicChefPlaylistEntry.fromJson(e.data()))
            .toList();
        final playlist = PublicChefPlaylist.fromJson(data, entries);
        loaded.add(playlist);
      }

      _playlists
        ..clear()
        ..addAll(loaded);

      debugPrint(
        'PublicChefPlaylistService: loaded ${_playlists.length} public playlists from Firestore',
      );
    } catch (e) {
      debugPrint('PublicChefPlaylistService: loadFromFirestore error $e');
    }
  }
}

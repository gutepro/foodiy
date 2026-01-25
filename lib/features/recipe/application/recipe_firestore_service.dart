import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/playlist/application/playlist_firestore_service.dart';
import 'package:foodiy/features/recipe/application/recipe_player_session_service.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';

class RecipeFirestoreService {
  RecipeFirestoreService._internal();

  static final RecipeFirestoreService instance =
      RecipeFirestoreService._internal();

  final _recipes = FirebaseFirestore.instance.collection('recipes');

  String newRecipeId() => _recipes.doc().id;

  Future<void> saveImportStub({
    required String recipeId,
    required String sourceFilePath,
    required String sourceType,
    String? originalDocumentUrl,
    String importStatus = 'uploading',
    String importStage = 'uploading',
    int progress = 0,
    String? errorMessage,
  }) async {
    final data = <String, dynamic>{
      'id': recipeId,
      'sourceType': sourceType,
      'sourceFilePath': sourceFilePath,
      'originalDocumentUrl': originalDocumentUrl,
      'importStatus': importStatus,
      'importStage': importStage,
      'progress': progress,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (errorMessage != null && errorMessage.isNotEmpty) {
      data['errorMessage'] = errorMessage;
    }
    await _recipes.doc(recipeId).set(data, SetOptions(merge: true));
  }

  Future<String> saveRecipe(Recipe recipe) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw StateError('Cannot save recipe: no authenticated user');
    }
    debugPrint(
      'RecipeFirestoreService.saveRecipe: start for title=${recipe.title}',
    );
    final doc = recipe.id.isNotEmpty ? _recipes.doc(recipe.id) : _recipes.doc();
    final data = recipe.toJson();
    data['id'] = doc.id;
    data['chefId'] = (data['chefId'] as String?)?.isNotEmpty == true
        ? data['chefId']
        : uid;
    // Recipe categories are removed from the product model.
    data.remove('categories');
    data.remove('category');
    data.remove('tags');
    data.remove('categoryKeys');
    // Normalize image fields so downstream readers can rely on coverImageUrl.
    final coverUrl = (data['coverImageUrl'] as String?)?.trim();
    final imageUrl = (data['imageUrl'] as String?)?.trim();
    data['coverImageUrl'] = coverUrl?.isNotEmpty == true
        ? coverUrl
        : (imageUrl?.isNotEmpty == true ? imageUrl : '');
    data['imageUrl'] = data['coverImageUrl'];
    data['sourceType'] = data['sourceType'] ?? 'manual';
    data['originalDocumentUrl'] = data['originalDocumentUrl'];
    // Never coerce unknown isPublic values to "true" - only publish when the
    // caller explicitly sets isPublic=true.
    data['isPublic'] = data['isPublic'] == true;
    data['views'] = data['views'] ?? 0;
    data['importStatus'] = data['importStatus'] ?? 'ready';
    data.putIfAbsent('createdAt', () => FieldValue.serverTimestamp());
    data['updatedAt'] = FieldValue.serverTimestamp();

    try {
      await doc.set(data, SetOptions(merge: true));
      debugPrint(
        'RecipeFirestoreService.saveRecipe: success for docId=${doc.id}',
      );
      debugPrint(
        '[RECIPE_SAVE] id=${doc.id} isPublic=${data['isPublic']} updatedAt=${data['updatedAt']}',
      );
      return doc.id;
    } catch (e) {
      debugPrint('RecipeFirestoreService: failed to save recipe ${doc.id}: $e');
      rethrow;
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    if (recipe.id.isEmpty) {
      throw ArgumentError('Recipe id is required for update');
    }
    final data = recipe.toJson();
    data.remove('categories');
    data.remove('category');
    data.remove('tags');
    data.remove('categoryKeys');
    data['isPublic'] = data['isPublic'] == true;
    data['updatedAt'] = FieldValue.serverTimestamp();
    data.remove('createdAt');
    await _recipes.doc(recipe.id).set(data, SetOptions(merge: true));
  }

  Future<Recipe?> getRecipeById(String id) async {
    debugPrint('RecipeFirestoreService.getRecipeById: recipes/$id');
    final snap = await _recipes.doc(id).get();
    if (!snap.exists) {
      debugPrint('RecipeFirestoreService.getRecipeById: not found for id=$id');
      return null;
    }
    final data = snap.data()!..['id'] = snap.id;
    return Recipe.fromJson(data, docId: snap.id);
  }

  Future<List<Recipe>> getPublicRecipes() async {
    final snapshot = await _recipes
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data()..['id'] = doc.id;
      return Recipe.fromJson(data, docId: doc.id);
    }).toList();
  }

  Stream<List<Recipe>> watchAllRecipes() {
    return _recipes
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data()..['id'] = doc.id;
            return Recipe.fromJson(data, docId: doc.id);
          }).toList();
        });
  }

  Stream<List<Recipe>> watchUserRecipes({required String uid, int? limit}) {
    if (uid.isEmpty) {
      return const Stream<List<Recipe>>.empty();
    }
    Query<Map<String, dynamic>> query = _recipes.where('chefId', isEqualTo: uid);
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots().map((snapshot) {
      final recipes = snapshot.docs.map((doc) {
        debugPrint('Home MyRecipes raw doc: ${doc.id} => ${doc.data()}');
        final data = doc.data()..['id'] = doc.id;
        return Recipe.fromJson(data, docId: doc.id);
      }).toList();
      recipes.sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      final limited = limit != null && recipes.length > limit
          ? recipes.sublist(0, limit)
          : recipes;
      debugPrint(
        'RecipeFirestoreService.watchUserRecipes: loaded ${limited.length}/${recipes.length} recipes for uid=$uid (sorted by updatedAt/createdAt)',
      );
      return limited;
    });
  }

  Future<List<Recipe>> fetchUserRecipesOnce({
    required String uid,
    int? limit,
  }) async {
    if (uid.isEmpty) return const [];
    Query<Map<String, dynamic>> query = _recipes.where('chefId', isEqualTo: uid);
    if (limit != null) {
      query = query.limit(limit);
    }
    final snapshot = await query.get();
    final recipes = snapshot.docs.map((doc) {
      final data = doc.data()..['id'] = doc.id;
      return Recipe.fromJson(data, docId: doc.id);
    }).toList();
    recipes.sort((a, b) {
      final aDate = a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    final limited = limit != null && recipes.length > limit
        ? recipes.sublist(0, limit)
        : recipes;
    debugPrint(
      'RecipeFirestoreService.fetchUserRecipesOnce: loaded ${limited.length}/${recipes.length} recipes for uid=$uid (sorted by updatedAt/createdAt)',
    );
    return limited;
  }

  Future<void> deleteRecipe(String recipeId) async {
    if (recipeId.isEmpty) return;
    await _recipes.doc(recipeId).delete();
    await PlaylistFirestoreService.instance.removeRecipeFromAllCookbooks(
      recipeId,
    );
    PersonalPlaylistService.instance.removeRecipeEverywhere(recipeId);
    final session = await RecipePlayerSessionService.instance.loadSession();
    if (session?.recipeId == recipeId) {
      await RecipePlayerSessionService.instance.clearSession();
    }
  }

  Future<Set<String>> getExistingRecipeIds(Iterable<String> recipeIds) async {
    final ids = recipeIds
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) return <String>{};
    const chunkSize = 10;
    final existing = <String>{};
    for (var i = 0; i < ids.length; i += chunkSize) {
      final end = (i + chunkSize) < ids.length ? i + chunkSize : ids.length;
      final chunk = ids.sublist(i, end);
      final snapshot = await _recipes
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      existing.addAll(snapshot.docs.map((doc) => doc.id));
    }
    return existing;
  }

  Future<List<Recipe>> fetchRecipesByIds(List<String> ids) async {
    final targetIds = ids.where((id) => id.isNotEmpty).toList();
    if (targetIds.isEmpty) return const [];
    const chunkSize = 10;
    final recipes = <Recipe>[];
    for (var i = 0; i < targetIds.length; i += chunkSize) {
      final end = (i + chunkSize) < targetIds.length
          ? i + chunkSize
          : targetIds.length;
      final chunk = targetIds.sublist(i, end);
      final snapshot = await _recipes
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      recipes.addAll(snapshot.docs.map((doc) {
        final data = doc.data()..['id'] = doc.id;
        return Recipe.fromJson(data, docId: doc.id);
      }));
    }
    return recipes;
  }
}

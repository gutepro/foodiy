import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:foodiy/features/recipe/domain/recipe.dart';

class RecipeFirestoreService {
  RecipeFirestoreService._internal();

  static final RecipeFirestoreService instance =
      RecipeFirestoreService._internal();

  final _recipes = FirebaseFirestore.instance.collection('recipes');

  String newRecipeId() => _recipes.doc().id;

  Future<String> saveRecipe(Recipe recipe) async {
    final doc =
        recipe.id.isNotEmpty ? _recipes.doc(recipe.id) : _recipes.doc();
    final data = recipe.toJson();
    data['id'] = doc.id;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    data['chefId'] = data['chefId'] ?? uid ?? '';
    data['isPublic'] = data['isPublic'] ?? true;
    data['views'] = data['views'] ?? 0;
    data.putIfAbsent('createdAt', () => FieldValue.serverTimestamp());
    data['updatedAt'] = FieldValue.serverTimestamp();
    await doc.set(data);
    return doc.id;
  }

  Future<void> updateRecipe(Recipe recipe) async {
    if (recipe.id.isEmpty) {
      throw ArgumentError('Recipe id is required for update');
    }
    final data = recipe.toJson();
    data.remove('createdAt');
    await _recipes.doc(recipe.id).update(data);
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

  Stream<List<Recipe>> watchUserRecipes({
    required String uid,
    int? limit,
  }) {
    if (uid.isEmpty) {
      return const Stream<List<Recipe>>.empty();
    }
    Query<Map<String, dynamic>> query = _recipes
        .where('chefId', isEqualTo: uid)
        .orderBy('createdAt', descending: true);
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots().map((snapshot) {
      final recipes = snapshot.docs.map((doc) {
        debugPrint('Home MyRecipes raw doc: ${doc.id} => ${doc.data()}');
        final data = doc.data()..['id'] = doc.id;
        return Recipe.fromJson(data, docId: doc.id);
      }).toList();
      debugPrint(
        'RecipeFirestoreService.watchUserRecipes: loaded ${recipes.length} recipes for uid=$uid',
      );
      return recipes;
    });
  }
}

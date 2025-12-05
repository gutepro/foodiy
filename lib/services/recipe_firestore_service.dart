import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recipe.dart';

class RecipeFirestoreService {
  RecipeFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('recipes');

  Future<List<Recipe>> fetchRecipes() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Recipe.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  Stream<List<Recipe>> watchRecipes() {
    return _collection.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Recipe.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }
}

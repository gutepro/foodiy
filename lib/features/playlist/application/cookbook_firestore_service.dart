import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CookbookFirestoreService {
  CookbookFirestoreService._();

  static final CookbookFirestoreService instance = CookbookFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String favoritesCookbookId(String ownerId) => 'favorites_$ownerId';

  Future<void> ensureFavoritesCookbook({
    required String ownerId,
    String title = 'Favorite recipes',
  }) async {
    if (ownerId.isEmpty) return;
    final favId = favoritesCookbookId(ownerId);
    final docRef = _firestore.collection('cookbooks').doc(favId);
    final snap = await docRef.get();
    if (snap.exists) {
      final existingOwner = (snap.data()?['ownerId'] ?? '') as String;
      if (existingOwner == ownerId) return;
      debugPrint(
        '[FAVORITES_GUARD] repairing owner for $favId existingOwner=$existingOwner -> $ownerId',
      );
    }
    await docRef.set({
      'id': favId,
      'ownerId': ownerId,
      'title': title,
      'name': title,
      'nameLower': title.toLowerCase(),
      'isPublic': false,
      'isSystem': true,
      'systemType': 'favorites',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'recipeIds': FieldValue.arrayUnion(<String>[]),
    }, SetOptions(merge: true));
  }

  Future<void> addRecipeToCookbook({
    required String cookbookId,
    required String recipeId,
    required String ownerId,
    String title = 'Cookbook',
    bool isPublic = false,
    String coverImageUrl = '',
  }) async {
    final docRef = _firestore.collection('cookbooks').doc(cookbookId);
    final recipeRef = FirebaseFirestore.instance.collection('recipes').doc(recipeId);
    debugPrint(
      '[ATTACH_WRITE] paths=cookbooks/$cookbookId,recipes/$recipeId fields=recipeIds+cookbookIds',
    );
    final snap = await docRef.get();
    final isFavorites = cookbookId.startsWith('favorites_');
    if (!snap.exists) {
      debugPrint(
        '[MIGRATION] cookbookId=$cookbookId missingRecipeIds -> initializing []',
      );
      await docRef.set({
        'id': cookbookId,
        'ownerId': ownerId,
        'title': isFavorites ? 'Favorite recipes' : title,
        'name': isFavorites ? 'Favorite recipes' : title,
        'nameLower': (isFavorites ? 'Favorite recipes' : title)
            .toLowerCase()
            .trim(),
        'coverImageUrl': coverImageUrl,
        'isPublic': false,
        if (isFavorites) ...{
          'isSystem': true,
          'systemType': 'favorites',
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'recipeIds': <String>[],
      }, SetOptions(merge: true));
    } else {
      final existingList = (snap.data()?['recipeIds'] as List<dynamic>?);
      if (existingList == null) {
        debugPrint(
          '[MIGRATION] cookbookId=$cookbookId missingRecipeIds -> initializing []',
        );
        await docRef.set({'recipeIds': <String>[]}, SetOptions(merge: true));
      }
    }
    if (isFavorites) {
      await ensureFavoritesCookbook(ownerId: ownerId, title: 'Favorite recipes');
    }
    final batch = _firestore.batch();
    batch.set(
      docRef,
      {
        'recipeIds': FieldValue.arrayUnion([recipeId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.set(
      recipeRef,
      {
        'cookbookIds': FieldValue.arrayUnion([cookbookId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
    final verifyCookbook = await docRef.get();
    final recipeIds =
        (verifyCookbook.data()?['recipeIds'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            const <String>[];
    final verifyRecipe = await recipeRef.get();
    final cookbookIds =
        (verifyRecipe.data()?['cookbookIds'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            const <String>[];
    final containsA = recipeIds.contains(recipeId);
    final containsB = cookbookIds.contains(cookbookId);
    if (!containsA || !containsB) {
      throw Exception(
        'ATTACH_VERIFY_FAILED path=cookbooks/$cookbookId recipeId=$recipeId cookbookIdsContains=$containsB recipeIdsContains=$containsA',
      );
    }
    debugPrint(
      '[ADD_VERIFY_OK] paths=cookbooks/$cookbookId,recipes/$recipeId recipeIdsCount=${recipeIds.length} cookbookIdsCount=${cookbookIds.length}',
    );
    debugPrint('ADD_TO_COOKBOOK success cookbookId=$cookbookId recipeId=$recipeId');
  }
}

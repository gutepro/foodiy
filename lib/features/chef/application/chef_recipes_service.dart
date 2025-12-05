import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/access_control_service.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/playlist/domain/personal_playlist_models.dart';

class ChefRecipeSummary {
  final String id;
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;
  final String chefId;
  final String? chefName;
  final String? chefAvatarUrl;
  final int views;
  final int playlistAdds;
  final bool isPublic;

  const ChefRecipeSummary({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
    this.chefId = '',
    this.chefName,
    this.chefAvatarUrl,
    this.views = 0,
    this.playlistAdds = 0,
    this.isPublic = true,
  });
}

class ChefRecipesService {
  ChefRecipesService._internal();

  static final ChefRecipesService _instance = ChefRecipesService._internal();
  static ChefRecipesService get instance => _instance;

  final List<ChefRecipeSummary> _recipes = [];
  static const int kFreeChefRecipeLimit = 5;

  // TODO: Add authorId to ChefRecipeSummary and filter by current user when Firestore is added.
  List<ChefRecipeSummary> getMyRecipes() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const [];
    }
    return List.unmodifiable(_recipes);
  }

  bool hasReachedFreeChefLimit() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    // TODO: When using Firestore, count recipes by authorId instead of _recipes length.
    return _recipes.length >= kFreeChefRecipeLimit;
  }

  void addRecipe(ChefRecipeSummary recipe) {
    _recipes.insert(0, recipe);
    final profile = CurrentUserService.instance.currentProfile;
    final userType = profile?.userType ?? UserType.freeUser;
    final access = AccessControlService.instance;

    if (access.isChef(userType)) {
      final playlistService = PersonalPlaylistService.instance;
      final entry = PersonalPlaylistEntry(
        recipeId: recipe.id,
        title: recipe.title,
        imageUrl: recipe.imageUrl,
        time: recipe.time,
        difficulty: recipe.difficulty,
      );
      playlistService.addToChefPlaylist(entry);
    } else {
      debugPrint(
        'ChefRecipesService: non chef user added recipe, not adding to chef playlist.',
      );
    }
    // TODO: Persist this in Firestore with authorId == current user uid.
  }

  void removeRecipe(String id) {
    _recipes.removeWhere((r) => r.id == id);
  }
}

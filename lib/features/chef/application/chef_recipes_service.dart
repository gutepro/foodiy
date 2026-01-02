import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/access_control_service.dart';
import 'package:foodiy/core/services/current_user_service.dart';
import 'package:foodiy/core/services/subscription_service.dart';
import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/playlist/domain/personal_playlist_models.dart';
import 'package:foodiy/features/recipe/application/recipe_firestore_service.dart';
import 'package:foodiy/features/recipe/domain/recipe.dart';

class ChefRecipeSummary {
  final String id;
  final String title;
  final String? imageUrl;
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
    required this.time,
    required this.difficulty,
    this.imageUrl,
    this.chefId = '',
    this.chefName,
    this.chefAvatarUrl,
    this.views = 0,
    this.playlistAdds = 0,
    this.isPublic = true,
  });

  ChefRecipeSummary copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? time,
    String? difficulty,
    String? chefId,
    String? chefName,
    String? chefAvatarUrl,
    int? views,
    int? playlistAdds,
    bool? isPublic,
  }) {
    return ChefRecipeSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      time: time ?? this.time,
      difficulty: difficulty ?? this.difficulty,
      chefId: chefId ?? this.chefId,
      chefName: chefName ?? this.chefName,
      chefAvatarUrl: chefAvatarUrl ?? this.chefAvatarUrl,
      views: views ?? this.views,
      playlistAdds: playlistAdds ?? this.playlistAdds,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}

class ChefRecipesService {
  ChefRecipesService._internal();

  static final ChefRecipesService _instance = ChefRecipesService._internal();
  static ChefRecipesService get instance => _instance;

  final List<ChefRecipeSummary> _recipes = [];
  static const int kFreeChefRecipeLimit = 10;
  StreamSubscription<List<Recipe>>? _recipesSub;
  int _recipesCount = 0;
  static const _followKey = 'following_chefs';
  final Set<String> _followingChefIds = <String>{};
  bool _followLoaded = false;

  // TODO: Add authorId to ChefRecipeSummary and filter by current user when Firestore is added.
  List<ChefRecipeSummary> getMyRecipes() {
    _ensureRecipeStream();
    return List.unmodifiable(_recipes);
  }

  bool hasReachedFreeChefLimit() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    _ensureRecipeStream();
    final count = _recipesCount > 0 ? _recipesCount : _recipes.length;
    return !SubscriptionService.instance.canUploadRecipe(
      currentRecipeCount: count,
    );
  }

  void addRecipe(ChefRecipeSummary recipe) {
    _recipes.insert(0, recipe);
    _recipesCount = _recipes.length;
    final profile = CurrentUserService.instance.currentProfile;
    final userType = profile?.userType ?? UserType.freeUser;
    final access = AccessControlService.instance;

    if (access.isChef(userType)) {
      final playlistService = PersonalPlaylistService.instance;
      final entry = PersonalPlaylistEntry(
        recipeId: recipe.id,
        title: recipe.title,
        imageUrl: recipe.imageUrl ?? '',
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
    _recipesCount = _recipes.length;
  }

  Future<void> deleteRecipe(String id) async {
    await RecipeFirestoreService.instance.deleteRecipe(id);
    removeRecipe(id);
  }

  void _ensureRecipeStream() {
    if (_recipesSub != null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    _recipesSub = RecipeFirestoreService.instance
        .watchUserRecipes(uid: uid)
        .listen((recipes) {
      _recipes
        ..clear()
        ..addAll(
          recipes.map(
            (r) => ChefRecipeSummary(
              id: r.id,
              title: r.title,
              imageUrl: r.coverImageUrl ?? r.imageUrl ?? '',
              time: '${r.steps.length} steps',
              difficulty: 'Medium',
              chefId: r.chefId,
              chefName: r.chefName,
              chefAvatarUrl: r.chefAvatarUrl,
              views: r.views,
              playlistAdds: r.playlistAdds,
              isPublic: r.isPublic,
            ),
          ),
        );
      _recipesCount = recipes.length;
      final tier = SubscriptionService.instance.currentTier;
      debugPrint(
        '[CHEF_RECIPES_STREAM] uid=$uid tier=$tier recipesCount=$_recipesCount',
      );
    });
  }

  Future<void> _ensureFollowLoaded() async {
    if (_followLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_followKey) ?? <String>[];
    _followingChefIds
      ..clear()
      ..addAll(ids);
    _followLoaded = true;
  }

  Future<bool> isFollowingChef(String chefId) async {
    await _ensureFollowLoaded();
    return _followingChefIds.contains(chefId);
  }

  Future<void> followChef(String chefId) async {
    await _ensureFollowLoaded();
    _followingChefIds.add(chefId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_followKey, _followingChefIds.toList());
  }

  Future<void> unfollowChef(String chefId) async {
    await _ensureFollowLoaded();
    _followingChefIds.remove(chefId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_followKey, _followingChefIds.toList());
  }
}

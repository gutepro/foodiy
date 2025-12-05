import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeAnalytics {
  final String recipeId;
  int views;
  int playlistAdds;

  RecipeAnalytics({
    required this.recipeId,
    this.views = 0,
    this.playlistAdds = 0,
  });

  Map<String, dynamic> toJson() => {
    'recipeId': recipeId,
    'views': views,
    'playlistAdds': playlistAdds,
  };

  factory RecipeAnalytics.fromJson(Map<String, dynamic> json) {
    return RecipeAnalytics(
      recipeId: json['recipeId'] as String,
      views: json['views'] as int? ?? 0,
      playlistAdds: json['playlistAdds'] as int? ?? 0,
    );
  }
}

class RecipeAnalyticsService {
  RecipeAnalyticsService._internal();

  static final RecipeAnalyticsService _instance =
      RecipeAnalyticsService._internal();
  static RecipeAnalyticsService get instance => _instance;

  final Map<String, RecipeAnalytics> _statsByRecipeId = {};
  static const _storageKey = 'recipe_analytics_v1';

  RecipeAnalytics _getOrCreate(String recipeId) {
    return _statsByRecipeId.putIfAbsent(
      recipeId,
      () => RecipeAnalytics(recipeId: recipeId),
    );
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return;
    try {
      final list = json.decode(jsonString) as List<dynamic>;
      _statsByRecipeId.clear();
      for (final item in list) {
        final stat = RecipeAnalytics.fromJson(item as Map<String, dynamic>);
        _statsByRecipeId[stat.recipeId] = stat;
      }
    } catch (e) {
      debugPrint('RecipeAnalyticsService: load error $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _statsByRecipeId.values.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(list));
    } catch (e) {
      debugPrint('RecipeAnalyticsService: save error $e');
    }
  }

  void recordView(String recipeId) {
    final stat = _getOrCreate(recipeId);
    stat.views++;
    debugPrint(
      'Analytics: recipe $recipeId views=${stat.views}, playlistAdds=${stat.playlistAdds}',
    );
    _saveToStorage();
    // TODO: send event to Firestore or analytics backend.
  }

  void recordPlaylistAdd(String recipeId) {
    final stat = _getOrCreate(recipeId);
    stat.playlistAdds++;
    debugPrint(
      'Analytics: recipe $recipeId views=${stat.views}, playlistAdds=${stat.playlistAdds}',
    );
    _saveToStorage();
    // TODO: send event to Firestore or analytics backend.
  }

  int getTotalViewsForRecipes(Iterable<String> recipeIds) {
    var total = 0;
    for (final id in recipeIds) {
      final stat = _statsByRecipeId[id];
      if (stat != null) {
        total += stat.views;
      }
    }
    return total;
  }

  int getTotalPlaylistAddsForRecipes(Iterable<String> recipeIds) {
    var total = 0;
    for (final id in recipeIds) {
      final stat = _statsByRecipeId[id];
      if (stat != null) {
        total += stat.playlistAdds;
      }
    }
    return total;
  }
}

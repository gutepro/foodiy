import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:foodiy/features/recipe/domain/recipe_step.dart';

class RecipeIngredient {
  final String name;
  final String quantity;
  final String unit;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
      };

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
    );
  }
}

class RecipeTool {
  final String name;

  const RecipeTool({required this.name});

  Map<String, dynamic> toJson() => {
        'name': name,
      };

  factory RecipeTool.fromJson(Map<String, dynamic> json) {
    return RecipeTool(
      name: json['name'] as String? ?? '',
    );
  }
}

class Recipe {
  final String id;
  final String originalLanguageCode;
  final String title;
  final String imageUrl;
  final List<RecipeStep> steps;
  final List<RecipeIngredient> ingredients;
  final List<RecipeTool> tools;
  final String preCookingNotes;
  final String chefId;
  final String? chefName;
  final String? chefAvatarUrl;
  final int views;
  final int playlistAdds;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Recipe({
    required this.id,
    required this.originalLanguageCode,
    required this.title,
    required this.imageUrl,
    required this.steps,
    this.ingredients = const [],
    this.tools = const [],
    this.preCookingNotes = '',
    this.chefId = '',
    this.chefName,
    this.chefAvatarUrl,
    this.views = 0,
    this.playlistAdds = 0,
    this.isPublic = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalLanguageCode': originalLanguageCode,
        'title': title,
        'imageUrl': imageUrl,
        'steps': steps.map((s) => s.toJson()).toList(),
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'tools': tools.map((t) => t.toJson()).toList(),
        'preCookingNotes': preCookingNotes,
        'chefId': chefId,
        'chefName': chefName,
        'chefAvatarUrl': chefAvatarUrl,
        'views': views,
        'playlistAdds': playlistAdds,
        'isPublic': isPublic,
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory Recipe.fromJson(Map<String, dynamic> json, {String docId = ''}) {
    debugPrint(
      'Recipe.fromJson: id=${json['id'] ?? docId}, '
      'ingredients raw=${json['ingredients']}, steps raw=${json['steps']}',
    );
    final rawIngredients = json['ingredients'];
    final rawSteps = json['steps'];
    final ingredientsList =
        rawIngredients is List ? rawIngredients : const <dynamic>[];
    final stepsList = rawSteps is List ? rawSteps : const <dynamic>[];
    return Recipe(
      id: json['id'] as String? ?? docId,
      originalLanguageCode: json['originalLanguageCode'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      steps: stepsList
          .asMap()
          .entries
          .map<RecipeStep>((entry) {
            final value = entry.value;
            final map = value is Map<String, dynamic>
                ? value
                : Map<String, dynamic>.from(value as Map);
            return RecipeStep.fromJson(map, index: entry.key);
          })
          .toList(),
      ingredients: ingredientsList
          .map<RecipeIngredient>((x) {
            final map = x is Map<String, dynamic>
                ? x
                : Map<String, dynamic>.from(x as Map);
            return RecipeIngredient.fromJson(map);
          })
          .toList(),
      tools: (json['tools'] as List<dynamic>? ?? [])
          .map<RecipeTool>(
              (x) => RecipeTool.fromJson(x as Map<String, dynamic>))
          .toList(),
      preCookingNotes: json['preCookingNotes'] as String? ?? '',
      chefId: json['chefId'] as String? ?? '',
      chefName: json['chefName'] as String?,
      chefAvatarUrl: json['chefAvatarUrl'] as String?,
      views: json['views'] as int? ?? 0,
      playlistAdds: json['playlistAdds'] as int? ?? 0,
      isPublic: json['isPublic'] as bool? ?? true,
      createdAt: (json['createdAt'] as dynamic)?.toDate(),
      updatedAt: (json['updatedAt'] as dynamic)?.toDate(),
    );
  }
}

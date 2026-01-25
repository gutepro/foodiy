import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'recipe_step.dart';

class Recipe {
  final String id;
  final String title;
  final String originalLanguageCode;
  final String imageUrl;
  final String coverImageUrl;
  final String sourceType;
  final List<RecipeStep> steps;
  final List<RecipeIngredient> ingredients;
  final List<RecipeTool> tools;
  final String preCookingNotes;
  final String chefId;
  final String? chefName;
  final String? chefAvatarUrl;
  final bool isPublic;
  final int views;
  final int playlistAdds;
  final DateTime? createdAt;
  final String importStatus;
  final int? timeEstimateSeconds;

  const Recipe({
    required this.id,
    required this.title,
    required this.originalLanguageCode,
    required this.imageUrl,
    required this.coverImageUrl,
    required this.sourceType,
    required this.steps,
    required this.ingredients,
    required this.tools,
    required this.preCookingNotes,
    required this.chefId,
    this.chefName,
    this.chefAvatarUrl,
    required this.isPublic,
    required this.views,
    required this.playlistAdds,
    this.createdAt,
    this.importStatus = 'ready',
    this.timeEstimateSeconds,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? originalLanguageCode,
    String? imageUrl,
    String? coverImageUrl,
    String? sourceType,
    List<RecipeStep>? steps,
    List<RecipeIngredient>? ingredients,
    List<RecipeTool>? tools,
    String? preCookingNotes,
    String? chefId,
    String? chefName,
    String? chefAvatarUrl,
    bool? isPublic,
    int? views,
    int? playlistAdds,
    DateTime? createdAt,
    String? importStatus,
    int? timeEstimateSeconds,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      originalLanguageCode:
          originalLanguageCode ?? this.originalLanguageCode,
      imageUrl: imageUrl ?? this.imageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      sourceType: sourceType ?? this.sourceType,
      steps: steps ?? this.steps,
      ingredients: ingredients ?? this.ingredients,
      tools: tools ?? this.tools,
      preCookingNotes: preCookingNotes ?? this.preCookingNotes,
      chefId: chefId ?? this.chefId,
      chefName: chefName ?? this.chefName,
      chefAvatarUrl: chefAvatarUrl ?? this.chefAvatarUrl,
      isPublic: isPublic ?? this.isPublic,
      views: views ?? this.views,
      playlistAdds: playlistAdds ?? this.playlistAdds,
      createdAt: createdAt ?? this.createdAt,
      importStatus: importStatus ?? this.importStatus,
      timeEstimateSeconds:
          timeEstimateSeconds ?? this.timeEstimateSeconds,
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json, String id) {
    final stepsJson = json['steps'] as List<dynamic>? ?? [];
    final ingredientsJson = json['ingredients'] as List<dynamic>? ?? [];
    final toolsJson = json['tools'] as List<dynamic>? ?? [];

    return Recipe(
      id: id,
      title: json['title'] as String? ?? '',
      originalLanguageCode:
          json['originalLanguageCode'] as String? ?? 'en',
      imageUrl: json['imageUrl'] as String? ?? '',
      coverImageUrl: (json['coverImageUrl'] as String?) ??
          (json['imageUrl'] as String? ?? ''),
      sourceType: json['sourceType'] as String? ?? 'manual',
      steps: stepsJson
          .map(
            (e) =>
                RecipeStep.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      ingredients: ingredientsJson
          .map(
            (e) =>
                RecipeIngredient.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      tools: toolsJson
          .map(
            (e) =>
                RecipeTool.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      preCookingNotes: json['preCookingNotes'] as String? ?? '',
      chefId: json['chefId'] as String? ?? '',
      chefName: json['chefName'] as String?,
      chefAvatarUrl: json['chefAvatarUrl'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      views: (json['views'] as num?)?.toInt() ?? 0,
      playlistAdds: (json['playlistAdds'] as num?)?.toInt() ?? 0,
      createdAt:
          (json['createdAt'] as Timestamp?)?.toDate(),
      importStatus: json['importStatus'] as String? ?? 'ready',
      timeEstimateSeconds:
          (json['timeEstimateSeconds'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'originalLanguageCode': originalLanguageCode,
      'imageUrl': imageUrl,
      'coverImageUrl': coverImageUrl,
      'sourceType': sourceType,
      'steps': steps.map((s) => s.toJson()).toList(),
      'ingredients':
          ingredients.map((i) => i.toJson()).toList(),
      'tools': tools.map((t) => t.toJson()).toList(),
      'preCookingNotes': preCookingNotes,
      'chefId': chefId,
      'chefName': chefName,
      'chefAvatarUrl': chefAvatarUrl,
      'isPublic': isPublic,
      'views': views,
      'playlistAdds': playlistAdds,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : null,
      'importStatus': importStatus,
      'timeEstimateSeconds': timeEstimateSeconds,
    };
  }
}

class RecipeIngredient {
  final String name;
  final String quantity;
  final String unit;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory RecipeIngredient.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecipeIngredient(
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

class RecipeTool {
  final String name;

  const RecipeTool({required this.name});

  factory RecipeTool.fromJson(Map<String, dynamic> json) {
    return RecipeTool(
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
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
  final String? imageUrl;
  final String? coverImageUrl;
  final List<String> categories;
  final String sourceType;
  final String? originalDocumentUrl;
  final String? sourceFilePath;
  final String importStatus;
  final String importStage;
  final String? importError;
  final String? errorMessage;
  final String status;
  final int progress;
  final String debugStage;
  final String? ocrStatus;
  final String? ocrRawText;
  final Map<String, dynamic>? ocrMeta;
  final Map<String, dynamic>? parseMeta;
  final Map<String, dynamic>? validationReport;
  final Map<String, dynamic>? importDebug;
  final bool needsReview;
  final List<String> issues;
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
    this.imageUrl,
    this.coverImageUrl,
    this.categories = const [],
    this.sourceType = 'manual',
    this.originalDocumentUrl,
    this.sourceFilePath,
    this.importStatus = 'ready',
    this.importStage = '',
    this.importError,
    this.errorMessage,
    this.status = 'ready',
    this.progress = 100,
    this.debugStage = '',
    this.ocrStatus,
    this.ocrRawText,
    this.ocrMeta,
    this.parseMeta,
    this.validationReport,
    this.importDebug,
    this.needsReview = false,
    this.issues = const [],
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

  Recipe copyWith({
    String? id,
    String? originalLanguageCode,
    String? title,
    String? imageUrl,
    String? coverImageUrl,
    List<String>? categories,
    String? sourceType,
    String? originalDocumentUrl,
    String? sourceFilePath,
    String? importStatus,
    String? importStage,
    String? importError,
    String? errorMessage,
    String? status,
    int? progress,
    String? debugStage,
    String? ocrStatus,
    String? ocrRawText,
    Map<String, dynamic>? ocrMeta,
    Map<String, dynamic>? parseMeta,
    Map<String, dynamic>? validationReport,
    Map<String, dynamic>? importDebug,
    bool? needsReview,
    List<String>? issues,
    List<RecipeStep>? steps,
    List<RecipeIngredient>? ingredients,
    List<RecipeTool>? tools,
    String? preCookingNotes,
    String? chefId,
    String? chefName,
    String? chefAvatarUrl,
    int? views,
    int? playlistAdds,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      originalLanguageCode:
          originalLanguageCode ?? this.originalLanguageCode,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      categories: categories ?? this.categories,
      sourceType: sourceType ?? this.sourceType,
      originalDocumentUrl: originalDocumentUrl ?? this.originalDocumentUrl,
      sourceFilePath: sourceFilePath ?? this.sourceFilePath,
      importStatus: importStatus ?? this.importStatus,
      importStage: importStage ?? this.importStage,
      importError: importError ?? this.importError,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      debugStage: debugStage ?? this.debugStage,
      ocrStatus: ocrStatus ?? this.ocrStatus,
      ocrRawText: ocrRawText ?? this.ocrRawText,
      ocrMeta: ocrMeta ?? this.ocrMeta,
      parseMeta: parseMeta ?? this.parseMeta,
      validationReport: validationReport ?? this.validationReport,
      importDebug: importDebug ?? this.importDebug,
      needsReview: needsReview ?? this.needsReview,
      issues: issues ?? this.issues,
      steps: steps ?? this.steps,
      ingredients: ingredients ?? this.ingredients,
      tools: tools ?? this.tools,
      preCookingNotes: preCookingNotes ?? this.preCookingNotes,
      chefId: chefId ?? this.chefId,
      chefName: chefName ?? this.chefName,
      chefAvatarUrl: chefAvatarUrl ?? this.chefAvatarUrl,
      views: views ?? this.views,
      playlistAdds: playlistAdds ?? this.playlistAdds,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalLanguageCode': originalLanguageCode,
        'title': title,
        'imageUrl': imageUrl,
        'coverImageUrl': coverImageUrl ?? imageUrl,
        'categories': categories,
        'sourceType': sourceType,
        'originalDocumentUrl': originalDocumentUrl,
        'sourceFilePath': sourceFilePath,
        'importStatus': importStatus,
        'importStage': importStage,
        'importError': importError,
        'errorMessage': errorMessage,
        'status': status,
        'progress': progress,
        'debugStage': debugStage,
        'ocrStatus': ocrStatus,
        'ocrRawText': ocrRawText,
        'ocrMeta': ocrMeta,
        'parseMeta': parseMeta,
        'validationReport': validationReport,
        'importDebug': importDebug,
        'needsReview': needsReview,
        'issues': issues,
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
    try {
      final rawIngredients = json['ingredients'];
      final rawSteps = json['steps'];
      final rawTools = json['tools'];
      Map<String, dynamic> _toMap(dynamic value) {
        if (value is Map<String, dynamic>) return value;
        if (value is Map) return Map<String, dynamic>.from(value as Map);
        return <String, dynamic>{};
      }
      List<String> _stringList(dynamic value) {
        if (value is List) {
          return value
              .whereType<String>()
              .map((v) => v.trim())
              .where((v) => v.isNotEmpty)
              .toList();
        }
        if (value is String && value.isNotEmpty) {
          return [value];
        }
        return <String>[];
      }
      Map<String, dynamic>? _mapOrNull(dynamic value) {
        if (value is Map<String, dynamic>) return value;
        if (value is Map) return Map<String, dynamic>.from(value as Map);
        return null;
      }
      final categories = _stringList(json['categories'] ?? json['category']);
      final ingredientsList =
          rawIngredients is List ? rawIngredients : const <dynamic>[];
      final stepsList = rawSteps is List ? rawSteps : const <dynamic>[];
      final img = (json['imageUrl'] ??
              json['image_url'] ??
              json['coverImageUrl'] ??
              json['cover_image_url']) as String?;
      final cover = (json['coverImageUrl'] ??
              json['cover_image_url'] ??
              img) as String?;
      DateTime? _toDate(dynamic value) {
        try {
          if (value is Timestamp) return value.toDate();
          if (value is DateTime) return value;
        } catch (_) {}
        return null;
      }
      final created = _toDate(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final updated = _toDate(json['updatedAt']) ?? created;
      final rawTitle = json['title'] as String?;
      final safeTitle =
          (rawTitle == null || rawTitle.trim().isEmpty) ? 'Imported recipe' : rawTitle;
      return Recipe(
        id: json['id'] as String? ?? docId,
        originalLanguageCode:
            json['originalLanguageCode'] as String? ?? '',
        title: safeTitle ?? 'Imported recipe',
        imageUrl: img ?? '',
        coverImageUrl: cover ?? '',
        categories: categories,
        sourceType: json['sourceType'] as String? ?? 'manual',
        originalDocumentUrl: json['originalDocumentUrl'] as String?,
        sourceFilePath: json['sourceFilePath'] as String?,
        importStatus: json['importStatus'] as String? ?? 'ready',
        importStage: json['importStage'] as String? ?? '',
        importError: json['importError'] as String?,
        errorMessage: json['errorMessage'] as String? ??
            (json['importError'] as String?),
        status: json['status'] as String? ?? 'ready',
        progress: json['progress'] as int? ?? 100,
        debugStage: json['debugStage'] as String? ?? '',
        ocrStatus: json['ocrStatus'] as String?,
        ocrRawText: json['ocrRawText'] as String?,
        ocrMeta: (json['ocrMeta'] as Map<String, dynamic>?),
        parseMeta: _mapOrNull(json['parseMeta']),
        validationReport: _mapOrNull(json['validationReport']),
        importDebug: _mapOrNull(json['importDebug']),
        needsReview: json['needsReview'] as bool? ?? false,
        issues: _stringList(json['issues']),
        steps: stepsList
            .asMap()
            .entries
            .map<RecipeStep>((entry) {
              final value = entry.value;
              if (value is String) {
                return RecipeStep(
                  text: value,
                  durationSeconds: null,
                );
              }
              final map = _toMap(value);
              return RecipeStep.fromJson(map, index: entry.key);
            })
            .toList(),
        ingredients: ingredientsList
            .map<RecipeIngredient>((x) {
              if (x is String) {
                return RecipeIngredient(name: x, quantity: '', unit: '');
              }
              final map = _toMap(x);
              return RecipeIngredient.fromJson(map);
            })
            .toList(),
        tools: (rawTools is List ? rawTools : const <dynamic>[])
            .map<RecipeTool>((x) {
              if (x is String) {
                return RecipeTool(name: x);
              }
              final map = _toMap(x);
              return RecipeTool.fromJson(map);
            })
            .toList(),
        preCookingNotes: json['preCookingNotes'] as String? ?? '',
        chefId: json['chefId'] as String? ?? '',
        chefName: json['chefName'] as String?,
        chefAvatarUrl: json['chefAvatarUrl'] as String?,
        views: json['views'] as int? ?? 0,
        playlistAdds: json['playlistAdds'] as int? ?? 0,
        isPublic: json['isPublic'] as bool? ?? true,
        createdAt: created,
        updatedAt: updated,
      );
    } catch (e, st) {
      debugPrint('Recipe.fromJson failed for id=$docId error=$e\n$st');
      return Recipe(
        id: docId,
        originalLanguageCode: '',
        title: '',
        imageUrl: '',
        coverImageUrl: '',
        categories: const [],
        sourceType: 'manual',
        originalDocumentUrl: null,
        sourceFilePath: null,
        importStatus: 'ready',
        importStage: '',
        importError: null,
        errorMessage: null,
        status: 'ready',
        progress: 100,
        debugStage: '',
        ocrStatus: null,
        ocrRawText: null,
        ocrMeta: null,
        parseMeta: null,
        validationReport: null,
        importDebug: null,
        needsReview: false,
        issues: const [],
        steps: const [],
        ingredients: const [],
        tools: const [],
        preCookingNotes: '',
        chefId: '',
        chefName: null,
        chefAvatarUrl: null,
        views: 0,
        playlistAdds: 0,
        isPublic: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
    }
  }
}

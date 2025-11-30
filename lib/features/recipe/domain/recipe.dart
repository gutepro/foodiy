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
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      unit: json['unit'] as String,
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
      name: json['name'] as String,
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

  const Recipe({
    required this.id,
    required this.originalLanguageCode,
    required this.title,
    required this.imageUrl,
    required this.steps,
    this.ingredients = const [],
    this.tools = const [],
    this.preCookingNotes = '',
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
      };

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      originalLanguageCode: json['originalLanguageCode'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      ingredients: (json['ingredients'] as List<dynamic>? ?? const [])
          .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      tools: (json['tools'] as List<dynamic>? ?? const [])
          .map((e) => RecipeTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      preCookingNotes: json['preCookingNotes'] as String? ?? '',
    );
  }
}

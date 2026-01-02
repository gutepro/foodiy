import 'package:flutter/foundation.dart';
import 'package:translator/translator.dart';

import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/features/recipe/domain/recipe_step.dart';

class RecipeTranslationService {
  RecipeTranslationService._internal();

  static final RecipeTranslationService instance =
      RecipeTranslationService._internal();

  final GoogleTranslator _translator = GoogleTranslator();
  final Map<String, Recipe> _cache = {};

  String _textFromResult(dynamic result) {
    if (result == null) return '';
    try {
      final text = result.text;
      if (text is String) return text;
    } catch (_) {
      // ignore and fall through
    }
    return result.toString();
  }

  Future<Recipe?> translateToEnglish(Recipe recipe) async {
    final origin = recipe.originalLanguageCode.toLowerCase();
    if (origin == 'en') return recipe;
    if (_cache.containsKey(recipe.id)) return _cache[recipe.id];
    try {
      final titleResult = await _translator.translate(
        recipe.title,
        from: origin.isEmpty ? 'auto' : origin,
        to: 'en',
      );
      final translatedTitle = _textFromResult(titleResult);
      final translatedIngredients = <RecipeIngredient>[];
      for (final ing in recipe.ingredients) {
        final nameResult = await _translator.translate(
          ing.name,
          from: origin.isEmpty ? 'auto' : origin,
          to: 'en',
        );
        final unitResult = ing.unit.isNotEmpty
            ? await _translator.translate(
                ing.unit,
                from: origin.isEmpty ? 'auto' : origin,
                to: 'en',
              )
            : null;
        translatedIngredients.add(
          RecipeIngredient(
            name: _textFromResult(nameResult),
            quantity: ing.quantity,
            unit: _textFromResult(unitResult ?? ''),
          ),
        );
      }
      final translatedSteps = <RecipeStep>[];
      for (final step in recipe.steps) {
        final textResult = await _translator.translate(
          step.text,
          from: origin.isEmpty ? 'auto' : origin,
          to: 'en',
        );
        translatedSteps.add(
          step.copyWith(text: _textFromResult(textResult)),
        );
      }
      final translatedRecipe = recipe.copyWith(
        title: translatedTitle,
        ingredients: translatedIngredients,
        steps: translatedSteps,
      );
      _cache[recipe.id] = translatedRecipe;
      return translatedRecipe;
    } catch (e, st) {
      debugPrint('RecipeTranslationService: translation failed: $e\n$st');
      return null;
    }
  }
}

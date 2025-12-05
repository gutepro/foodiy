import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../domain/cookbook_models.dart';

class CookbookService {
  CookbookService._internal();

  static final CookbookService _instance = CookbookService._internal();
  static CookbookService get instance => _instance;

  final _uuid = const Uuid();
  final List<Cookbook> _cookbooks = [];

  List<Cookbook> get cookbooks => List.unmodifiable(_cookbooks);

  Cookbook createCookbook(String name) {
    final book = Cookbook(
      id: _uuid.v4(),
      name: name,
    );
    _cookbooks.insert(0, book);
    debugPrint('CookbookService: created cookbook "${book.name}" with id ${book.id}');
    return book;
  }

  void removeCookbook(String id) {
    _cookbooks.removeWhere((c) => c.id == id);
    debugPrint('CookbookService: removed cookbook $id');
  }

  void renameCookbook(String id, String newName) {
    final book = _cookbooks.firstWhere(
      (c) => c.id == id,
      orElse: () => Cookbook(id: id, name: 'Unknown'),
    );
    book.name = newName;
    debugPrint('CookbookService: renamed cookbook $id to $newName');
  }

  List<CookbookRecipeEntry> getRecipesForCookbook(String cookbookId) {
    final book = _cookbooks.firstWhere(
      (c) => c.id == cookbookId,
      orElse: () => Cookbook(id: cookbookId, name: 'Unknown'),
    );
    return List.unmodifiable(book.recipes);
  }

  void addRecipeToCookbook(String cookbookId, CookbookRecipeEntry entry) {
    final book = _cookbooks.firstWhere(
      (c) => c.id == cookbookId,
      orElse: () => Cookbook(id: cookbookId, name: 'Unknown'),
    );

    final alreadyExists = book.recipes.any((e) => e.recipeId == entry.recipeId);
    if (alreadyExists) {
      debugPrint('CookbookService: recipe ${entry.recipeId} already exists in "${book.name}"');
      return;
    }

    book.recipes.add(entry);

    debugPrint(
      'CookbookService: added recipe ${entry.recipeId} to "${book.name}". '
      'Now has ${book.recipes.length} recipes.',
    );
  }

  int getRecipeCountForCookbook(String cookbookId) {
    final book = _cookbooks.firstWhere(
      (c) => c.id == cookbookId,
      orElse: () => Cookbook(id: cookbookId, name: 'Unknown'),
    );
    return book.recipes.length;
  }

  // TODO: Persist cookbooks and their recipes to Firestore per user.
}

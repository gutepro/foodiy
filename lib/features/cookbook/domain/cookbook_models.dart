class CookbookRecipeEntry {
  final String recipeId;
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;

  const CookbookRecipeEntry({
    required this.recipeId,
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
  });
}

class Cookbook {
  final String id;
  String name;
  final List<CookbookRecipeEntry> recipes;

  Cookbook({
    required this.id,
    required this.name,
    List<CookbookRecipeEntry>? recipes,
  }) : recipes = recipes ?? <CookbookRecipeEntry>[];
}

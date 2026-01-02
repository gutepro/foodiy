class RecipeCategory {
  final String key;
  final String title;
  const RecipeCategory({required this.key, required this.title});
}

const List<RecipeCategory> kRecipeCategoryOptions = [
  RecipeCategory(key: 'breakfast', title: 'Breakfast'),
  RecipeCategory(key: 'brunch', title: 'Brunch'),
  RecipeCategory(key: 'quick-weeknight-dinners', title: 'Quick Weeknight Dinners'),
  RecipeCategory(key: 'friday-lunch', title: 'Friday Lunch'),
  RecipeCategory(key: 'comfort-food', title: 'Comfort Food'),
  RecipeCategory(key: 'baking-basics', title: 'Baking Basics'),
  RecipeCategory(key: 'bread-and-dough', title: 'Bread & Dough'),
  RecipeCategory(key: 'pastries', title: 'Pastries'),
  RecipeCategory(key: 'cakes-and-desserts', title: 'Cakes & Desserts'),
  RecipeCategory(key: 'cookies-and-small-sweets', title: 'Cookies & Small Sweets'),
  RecipeCategory(key: 'chocolate-lovers', title: 'Chocolate Lovers'),
  RecipeCategory(key: 'healthy-and-light', title: 'Healthy & Light'),
  RecipeCategory(key: 'high-protein', title: 'High Protein'),
  RecipeCategory(key: 'vegetarian', title: 'Vegetarian'),
  RecipeCategory(key: 'vegan', title: 'Vegan'),
  RecipeCategory(key: 'gluten-free', title: 'Gluten Free'),
  RecipeCategory(key: 'one-pot-meals', title: 'One Pot Meals'),
  RecipeCategory(key: 'soups-and-stews', title: 'Soups & Stews'),
  RecipeCategory(key: 'salads', title: 'Salads'),
  RecipeCategory(key: 'pasta-and-risotto', title: 'Pasta & Risotto'),
  RecipeCategory(key: 'rice-and-grains', title: 'Rice & Grains'),
  RecipeCategory(key: 'middle-eastern', title: 'Middle Eastern'),
  RecipeCategory(key: 'italian-classics', title: 'Italian Classics'),
  RecipeCategory(key: 'asian-inspired', title: 'Asian Inspired'),
  RecipeCategory(key: 'street-food', title: 'Street Food'),
  RecipeCategory(key: 'family-favorites', title: 'Family Favorites'),
  RecipeCategory(key: 'hosting-and-holidays', title: 'Hosting & Holidays'),
  RecipeCategory(key: 'meal-prep', title: 'Meal Prep'),
  RecipeCategory(key: 'kids-friendly', title: 'Kids Friendly'),
  RecipeCategory(key: 'late-night-cravings', title: 'Late Night Cravings'),
];

Map<String, String> get kCategoryTitleByKey => {
  for (final c in kRecipeCategoryOptions) c.key: c.title,
};

String categoryKeyFromInput(String value) {
  final trimmed = value.trim();
  final found = kRecipeCategoryOptions.firstWhere(
    (c) => c.title.toLowerCase() == trimmed.toLowerCase() || c.key == trimmed,
    orElse: () => const RecipeCategory(key: '', title: ''),
  );
  if (found.key.isNotEmpty) return found.key;
  final slug = trimmed
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'(^-|-$)'), '');
  return slug;
}

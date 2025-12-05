import 'package:foodiy/features/profile/domain/user_profile_models.dart';

class UserProfileService {
  UserProfileService._internal();

  static final UserProfileService _instance = UserProfileService._internal();
  static UserProfileService get instance => _instance;

  final List<SavedRecipeSummary> _savedRecipes = [];
  final List<UserActivityItem> _activity = [];
  // TODO: Integrate savedRecipes into a proper personal playlist system instead of a separate "saved" section.

  List<SavedRecipeSummary> get savedRecipes => List.unmodifiable(_savedRecipes);
  List<UserActivityItem> get activity => List.unmodifiable(_activity);

  void logActivity(String description) {
    _activity.insert(
      0,
      UserActivityItem(timestamp: DateTime.now(), description: description),
    );
  }

  bool isRecipeSaved(String recipeId) {
    return _savedRecipes.any((r) => r.id == recipeId);
  }

  void saveRecipe(SavedRecipeSummary recipe) {
    if (isRecipeSaved(recipe.id)) return;
    _savedRecipes.insert(0, recipe);
    logActivity('Saved recipe: ${recipe.title}');
  }

  void removeSavedRecipe(String recipeId) {
    final index = _savedRecipes.indexWhere((r) => r.id == recipeId);
    if (index == -1) return;
    final removed = _savedRecipes.removeAt(index);
    logActivity('Removed saved recipe: ${removed.title}');
  }

  // TODO: Persist saved recipes and activity to Firestore for the logged in user.
}

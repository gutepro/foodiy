import 'package:foodiy/features/cookbook/application/cookbook_service.dart';
import 'package:foodiy/features/cookbook/domain/cookbook_models.dart';

class CookbookShareHelper {
  static String formatCookbook(
    Cookbook book,
    CookbookService service,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('Cookbook: ${book.name}');
    buffer.writeln('');

    final recipes = service.getRecipesForCookbook(book.id);
    if (recipes.isEmpty) {
      buffer.writeln('No recipes in this cookbook yet.');
      return buffer.toString();
    }

    for (final r in recipes) {
      buffer.writeln('- ${r.title} (${r.time}, ${r.difficulty})');
    }

    return buffer.toString();
  }
}

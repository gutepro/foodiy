import 'shopping_item.dart';

class ShoppingList {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<ShoppingItem> items;

  const ShoppingList({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.items,
  });
}

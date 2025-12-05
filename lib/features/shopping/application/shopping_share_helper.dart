import 'package:foodiy/features/shopping/application/shopping_list_service.dart';

class ShoppingShareHelper {
  static String formatCurrentList(ShoppingListService service) {
    final items = service.items;
    if (items.isEmpty) {
      return 'Shopping list is empty.';
    }

    final buffer = StringBuffer();
    buffer.writeln('Shopping list:');
    buffer.writeln('');

    for (final item in items) {
      final checkbox = item.isChecked ? '[x]' : '[ ]';
      final quantityPart =
          item.quantity.isNotEmpty ? ' - ${item.quantity}' : '';
      buffer.writeln('$checkbox ${item.name}$quantityPart');
    }

    return buffer.toString();
  }

  static String formatSnapshot(ShoppingListSnapshot snapshot) {
    final buffer = StringBuffer();
    buffer.writeln(snapshot.title);
    buffer.writeln('Created: ${snapshot.createdAt.toLocal()}');
    buffer.writeln('Finished: ${snapshot.finishedAt.toLocal()}');
    buffer.writeln('');

    if (snapshot.items.isEmpty) {
      buffer.writeln('No items in this list.');
      return buffer.toString();
    }

    for (final item in snapshot.items) {
      final checkbox = item.isChecked ? '[x]' : '[ ]';
      final quantityPart =
          item.quantity.isNotEmpty ? ' - ${item.quantity}' : '';
      buffer.writeln('$checkbox ${item.name}$quantityPart');
    }

    return buffer.toString();
  }
}

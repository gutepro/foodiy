import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:foodiy/features/shopping/application/shopping_list_service.dart';
import 'package:foodiy/features/shopping/application/shopping_share_helper.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';

class ShoppingHistoryDetailsArgs {
  final String listId;
  const ShoppingHistoryDetailsArgs({required this.listId});
}

class ShoppingHistoryDetailsScreen extends StatelessWidget {
  const ShoppingHistoryDetailsScreen({super.key, required this.args});

  final ShoppingHistoryDetailsArgs args;

  @override
  Widget build(BuildContext context) {
    final service = ShoppingListService.instance;
    ShoppingListSnapshot? snapshot;
    try {
      snapshot = service.history.firstWhere((s) => s.id == args.listId);
    } catch (_) {
      snapshot = null;
    }

    if (snapshot == null) {
      return Scaffold(
        appBar: const FoodiyAppBar(title: Text('Shopping history')),
        body: const Center(
          child: Text('List not found'),
        ),
      );
    }

    final list = snapshot;

    return Scaffold(
      appBar: FoodiyAppBar(
        title: Text(list.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share this list',
            onPressed: () {
              final text = ShoppingShareHelper.formatSnapshot(list);
              Share.share(
                text,
                subject: list.title,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Created: ${_formatDateTime(list.createdAt)}'),
            Text('Finished: ${_formatDateTime(list.finishedAt)}'),
            const SizedBox(height: 16),
            Text(
              'Items',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: list.items.length,
                itemBuilder: (context, index) {
                  final item = list.items[index];
                  return ListTile(
                    leading: Icon(
                      item.isChecked
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    title: Text(item.name),
                    subtitle: item.quantityText.isNotEmpty
                        ? Text(item.quantityText)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

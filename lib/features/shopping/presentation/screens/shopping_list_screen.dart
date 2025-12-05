import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import 'package:foodiy/features/shopping/application/shopping_list_service.dart';
import 'package:foodiy/features/shopping/application/shopping_share_helper.dart';
import 'package:foodiy/router/app_routes.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _service = ShoppingListService.instance;

  @override
  Widget build(BuildContext context) {
    final items = _service.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping list'),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist_rtl),
            tooltip: 'Finish and archive',
            onPressed: items.isEmpty ? null : _onFinishListPressed,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => context.push(AppRoutes.shoppingHistory),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share list',
            onPressed: _onShareCurrentListPressed,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add item',
            onPressed: _onAddManualItemPressed,
          ),
          IconButton(
            tooltip: 'Clear all',
            icon: const Icon(Icons.delete_outline),
            onPressed: items.isEmpty
                ? null
                : () {
                    _service.clear();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Shopping list cleared'),
                      ),
                    );
                  },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: items.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: EdgeInsets.only(top: index == 0 ? 0 : 12),
                    child: CheckboxListTile(
                      value: item.isChecked,
                      onChanged: (_) => _toggleItem(item.id),
                      title: Text('${item.name} - ${item.quantity}'),
                      secondary: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeItem(item.id),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _toggleItem(String id) {
    setState(() {
      _service.toggleItem(id);
    });
  }

  void _removeItem(String id) {
    setState(() {
      _service.removeItem(id);
    });
  }

  void _onFinishListPressed() {
    if (_service.items.isEmpty) return;

    _service.finishCurrentList(title: 'Shopping list');
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shopping list moved to history')),
    );
  }

  void _onShareCurrentListPressed() {
    if (_service.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shopping list is empty')),
      );
      return;
    }

    final text = ShoppingShareHelper.formatCurrentList(_service);
    Share.share(
      text,
      subject: 'My shopping list',
    );
  }

  Future<void> _onAddManualItemPressed() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add item to shopping list'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity (optional)',
                  hintText: 'For example: 2 packs, 1 bottle',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an item name'),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    final name = nameController.text.trim();
    final quantity = quantityController.text.trim();

    final uuid = const Uuid();
    final item = ShoppingListItem(
      id: uuid.v4(),
      name: name,
      quantity: quantity,
    );

    _service.addItems([item]);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added "$name" to shopping list')),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: color),
          const SizedBox(height: 12),
          const Text('No items yet'),
          const SizedBox(height: 4),
          const Text('Add ingredients from a recipe'),
        ],
      ),
    );
  }
}

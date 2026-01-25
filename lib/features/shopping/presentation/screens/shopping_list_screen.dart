import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:printing/printing.dart';

import 'package:foodiy/features/shopping/application/shopping_list_service.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen>
    with WidgetsBindingObserver {
  final _service = ShoppingListService.instance;
  final _nameController = TextEditingController();
  ShoppingListItem? _lastRemoved;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _service.addListener(_onServiceChanged);
    _service.ensureListening();
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _service.ensureListening();
    }
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = _service.items;

    return Scaffold(
      appBar: FoodiyAppBar(
        title: const Text('Shopping list'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print list',
            onPressed: items.isEmpty ? null : _onPrintPressed,
          ),
          IconButton(
            tooltip: 'Clear checked items',
            icon: const Icon(Icons.check_circle_outline),
            onPressed: items.any((i) => i.isChecked)
                ? _clearCheckedItems
                : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: _AddManualItemRow(
                nameController: _nameController,
                onAdd: _addManualItem,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _ShoppingItemRow(
                          item: item,
                          onToggle: () => _toggleItem(item.id),
                          onDelete: () => _removeItem(item.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleItem(String id) async {
    try {
      await _service.toggleItem(id);
    } catch (e) {
      if (!mounted) return;
      _showError('Could not update item. Please try again.');
    }
  }

  Future<void> _clearCheckedItems() async {
    final checked = _service.items.where((i) => i.isChecked).toList();
    try {
      for (final item in checked) {
        await _service.removeItem(item.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cleared checked items')),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Could not clear items. Check your connection.');
    }
  }

  Future<void> _onPrintPressed() async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Printing is not supported in web preview.')),
      );
      return;
    }
    if (_service.items.isEmpty) return;
    try {
      // Keep it simple: print all items (checked + unchecked), names only.
      final buffer = StringBuffer();
      buffer.writeln('Shopping List');
      buffer.writeln('');
      for (final item in _service.items) {
        final checkbox = item.isChecked ? '[x]' : '[ ]';
        buffer.writeln('$checkbox ${item.name}');
      }
      await Printing.layoutPdf(
        onLayout: (format) => Printing.convertHtml(
          format: format,
          html: _buildPrintHtml(buffer.toString()),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Printing is unavailable: $e')),
      );
    }
  }

  String _buildPrintHtml(String text) {
    final lines = text.split('\n');
    final buffer = StringBuffer();
    buffer.writeln('<html><body style="font-family: Arial, sans-serif;">');
    for (final line in lines) {
      if (line.startsWith('[')) {
        buffer.writeln(
            '<div style="margin:4px 0;font-size:16px;">$line</div>');
      } else if (line.startsWith('Shopping List')) {
        buffer.writeln(
            '<h2 style="margin-bottom:4px;">$line</h2>');
      } else {
        buffer.writeln(
            '<div style="margin:2px 0;color:#444;">$line</div>');
      }
    }
    buffer.writeln('</body></html>');
    return buffer.toString();
  }

  Future<void> _addManualItem() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item name')),
      );
      return;
    }
    final uuid = const Uuid();
    final item = ShoppingListItem(
      id: uuid.v4(),
      userId: '',
      name: name,
      quantityText: '',
      createdAt: DateTime.now(),
      isCustom: true,
      isChecked: false,
    );
    try {
      await _service.addItems([item]);
    } catch (e) {
      if (!mounted) return;
      _showError('Could not add that item. Check your connection.');
      return;
    }
    _nameController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added "$name" to shopping list')),
    );
  }

  Future<void> _removeItem(String id) async {
    final item = _service.items.firstWhere(
      (i) => i.id == id,
      orElse: () => ShoppingListItem(
        id: '',
        userId: '',
        name: '',
        quantityText: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    if (item.id.isEmpty) return;
    _lastRemoved = item;
    try {
      await _service.removeItem(id);
    } catch (e) {
      if (!mounted) return;
      _showError('Could not remove that item. Please try again.');
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${item.name}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final removed = _lastRemoved;
            if (removed != null) {
              try {
                await _service.addItems(
                  [removed.copyWith(isChecked: false)],
                );
              } catch (_) {
                if (!mounted) return;
                _showError('Undo failed. Check your connection.');
              }
            }
          },
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
          const Text(
            'Your shopping list is empty',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add ingredients from a recipe or type items manually.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AddManualItemRow extends StatelessWidget {
  const _AddManualItemRow({
    this.nameController,
    this.onAdd,
  });

  final TextEditingController? nameController;
  final Future<void> Function()? onAdd;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: nameController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onAdd?.call(),
                decoration: const InputDecoration(
                  hintText: 'Add item (e.g., Tomatoes)',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: ElevatedButton.icon(
                onPressed: onAdd == null ? null : () => onAdd!(),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  minimumSize: const Size(0, 44),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingItemRow extends StatelessWidget {
  const _ShoppingItemRow({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  final ShoppingListItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = item.isChecked
        ? theme.textTheme.titleMedium?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: theme.disabledColor,
          )
        : theme.textTheme.titleMedium;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: item.isChecked,
                onChanged: (_) => onToggle(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.name,
                style: textStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remove',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

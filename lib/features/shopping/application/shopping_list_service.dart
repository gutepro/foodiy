import 'package:uuid/uuid.dart';

class ShoppingListItem {
  final String id;
  final String name;
  final String quantity;
  final bool isChecked;

  const ShoppingListItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.isChecked = false,
  });

  ShoppingListItem copyWith({
    String? id,
    String? name,
    String? quantity,
    bool? isChecked,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

class _ParsedQuantity {
  final int value;
  final String unitText;

  const _ParsedQuantity(this.value, this.unitText);
}

class ShoppingListSnapshot {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime finishedAt;
  final List<ShoppingListItem> items;

  const ShoppingListSnapshot({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.finishedAt,
    required this.items,
  });
}

class ShoppingListService {
  ShoppingListService._internal();

  static final ShoppingListService _instance = ShoppingListService._internal();
  static ShoppingListService get instance => _instance;

  final _uuid = const Uuid();
  final List<ShoppingListItem> _items = [];
  DateTime? _createdAt;
  final List<ShoppingListSnapshot> _history = [];

  List<ShoppingListItem> get items => List.unmodifiable(_items);
  List<ShoppingListSnapshot> get history => List.unmodifiable(_history);

  void addItems(List<ShoppingListItem> newItems) {
    if (_items.isEmpty) {
      _createdAt = DateTime.now();
    }
    for (final newItem in newItems) {
      _addOrMergeItem(newItem);
    }
  }

  void toggleItem(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    final item = _items[index];
    _items[index] = item.copyWith(isChecked: !item.isChecked);
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
  }

  void clear() {
    _items.clear();
    _createdAt = null;
  }

  void finishCurrentList({String title = 'Shopping list'}) {
    if (_items.isEmpty) return;

    final snapshot = ShoppingListSnapshot(
      id: _uuid.v4(),
      title: title,
      createdAt: _createdAt ?? DateTime.now(),
      finishedAt: DateTime.now(),
      items: List<ShoppingListItem>.from(_items),
    );

    _history.insert(0, snapshot);
    _items.clear();
    _createdAt = null;
  }

  String _normalizeName(String name) {
    return name.trim().toLowerCase();
  }

  _ParsedQuantity? _parseQuantity(String quantity) {
    // TODO: If quantity format changes, refine parsing to handle fractions/decimals.
    final trimmed = quantity.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split(RegExp(r'\s+'));
    final first = parts.first;

    final value = int.tryParse(first);
    if (value == null) {
      return null;
    }

    final unitText = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return _ParsedQuantity(value, unitText);
  }

  void _addOrMergeItem(ShoppingListItem newItem) {
    final normalizedNewName = _normalizeName(newItem.name);
    final newParsed = _parseQuantity(newItem.quantity);

    final index = _items.indexWhere(
      (item) => _normalizeName(item.name) == normalizedNewName,
    );

    if (index == -1) {
      _items.add(newItem);
      return;
    }

    final existing = _items[index];
    final existingParsed = _parseQuantity(existing.quantity);

    if (newParsed == null || existingParsed == null) {
      _items.add(newItem);
      return;
    }

    if (existingParsed.unitText != newParsed.unitText) {
      _items.add(newItem);
      return;
    }

    final summed = existingParsed.value + newParsed.value;
    final newQuantityText =
        newParsed.unitText.isEmpty ? summed.toString() : '$summed ${newParsed.unitText}';

    _items[index] = existing.copyWith(quantity: newQuantityText);
  }

  // TODO: persist shopping list in Firestore later
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class ShoppingListItem {
  final String id;
  final String userId;
  final String name;
  final String quantityText;
  final bool isChecked;
  final DateTime createdAt;
  final String? sourceRecipeId;
  final String? sourceRecipeTitle;
  final bool isCustom;

  const ShoppingListItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.quantityText,
    this.isChecked = false,
    required this.createdAt,
    this.sourceRecipeId,
    this.sourceRecipeTitle,
    this.isCustom = true,
  });

  ShoppingListItem copyWith({
    String? id,
    String? userId,
    String? name,
    String? quantityText,
    bool? isChecked,
    DateTime? createdAt,
    String? sourceRecipeId,
    String? sourceRecipeTitle,
    bool? isCustom,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      quantityText: quantityText ?? this.quantityText,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
      sourceRecipeId: sourceRecipeId ?? this.sourceRecipeId,
      sourceRecipeTitle: sourceRecipeTitle ?? this.sourceRecipeTitle,
      isCustom: isCustom ?? this.isCustom,
    );
  }
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

class ShoppingListService with ChangeNotifier {
  ShoppingListService._internal();

  static final ShoppingListService _instance = ShoppingListService._internal();
  static ShoppingListService get instance => _instance;

  final _uuid = const Uuid();
  final List<ShoppingListItem> _items = [];
  DateTime? _createdAt;
  final List<ShoppingListSnapshot> _history = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  bool _listening = false;
  String? _listeningUid;

  final _collection =
      FirebaseFirestore.instance.collection('shoppingCarts');

  List<ShoppingListItem> get items => List.unmodifiable(_items);
  List<ShoppingListSnapshot> get history => List.unmodifiable(_history);

  Future<void> ensureListening() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (_listening && _listeningUid == uid && _subscription != null) return;
    _listeningUid = uid;
    await _startListening();
  }

  Future<void> _startListening() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _subscription?.cancel();
    if (uid == null || uid.isEmpty) {
      _items.clear();
      _listening = false;
      notifyListeners();
      return;
    }
    _subscription = _collection
        .doc(uid)
        .collection('items')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen(
      (snapshot) {
        _items
          ..clear()
          ..addAll(snapshot.docs.map(_fromDoc));
        notifyListeners();
      },
      onError: (_) {
        _listening = false;
      },
    );
    _listening = true;
  }

  Future<void> addItems(List<ShoppingListItem> newItems) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('User not signed in');
    }
    final now = DateTime.now();
    if (_items.isEmpty) _createdAt = now;

    // Optimistically update UI so taps feel instant.
    final resolvedItems = newItems
        .map(
          (item) => item.copyWith(
            id: item.id.isNotEmpty ? item.id : _uuid.v4(),
            userId: uid,
            createdAt: item.createdAt,
          ),
        )
        .toList();
    _items.addAll(resolvedItems);
    notifyListeners();

    final batch = FirebaseFirestore.instance.batch();
    for (final item in resolvedItems) {
      final doc = _collection
          .doc(uid)
          .collection('items')
          .doc(item.id);
      batch.set(doc, _toMap(item.copyWith(userId: uid, createdAt: now)));
    }
    try {
      await batch.commit();
    } catch (e) {
      // Roll back optimistic add on failure.
      _items.removeWhere((item) => resolvedItems.any((r) => r.id == item.id));
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleItem(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    final item = _items[index];
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('User not signed in');
    }

    final updated = item.copyWith(isChecked: !item.isChecked);
    _items[index] = updated;
    notifyListeners();

    try {
      await _collection
          .doc(uid)
          .collection('items')
          .doc(id)
          .update({'isChecked': updated.isChecked});
    } catch (e) {
      // Revert on failure so UI stays consistent.
      _items[index] = item;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeItem(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('User not signed in');
    }

    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    final removed = _items.removeAt(index);
    notifyListeners();

    try {
      await _collection.doc(uid).collection('items').doc(id).delete();
    } catch (e) {
      _items.insert(index, removed);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clear() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('User not signed in');
    }
    final previous = List<ShoppingListItem>.from(_items);
    _items.clear();
    _createdAt = null;
    notifyListeners();

    final docs =
        await _collection.doc(uid).collection('items').get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in docs.docs) {
      batch.delete(doc.reference);
    }
    try {
      await batch.commit();
    } catch (e) {
      // Restore list if clear fails.
      _items
        ..clear()
        ..addAll(previous);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> finishCurrentList({String title = 'Shopping list'}) async {
    if (_items.isEmpty) return;

    final snapshot = ShoppingListSnapshot(
      id: _uuid.v4(),
      title: title,
      createdAt: _createdAt ?? DateTime.now(),
      finishedAt: DateTime.now(),
      items: List<ShoppingListItem>.from(_items),
    );

    _history.insert(0, snapshot);
    await clear();
  }

  // TODO: persist shopping list in Firestore later
  Map<String, dynamic> _toMap(ShoppingListItem item) {
    return {
      'id': item.id,
      'userId': item.userId,
      'name': item.name,
      'quantityText': item.quantityText,
      'isChecked': item.isChecked,
      'createdAt': item.createdAt.millisecondsSinceEpoch,
      'sourceRecipeId': item.sourceRecipeId,
      'sourceRecipeTitle': item.sourceRecipeTitle,
      'isCustom': item.isCustom,
    };
  }

  ShoppingListItem _fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return ShoppingListItem(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      quantityText: data['quantityText'] as String? ?? '',
      isChecked: data['isChecked'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (data['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
      sourceRecipeId: data['sourceRecipeId'] as String?,
      sourceRecipeTitle: data['sourceRecipeTitle'] as String?,
      isCustom: data['isCustom'] as bool? ?? true,
    );
  }
}

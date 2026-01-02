import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:foodiy/shared/constants/categories.dart';

class CategoryMigrationService {
  CategoryMigrationService._();

  static final CategoryMigrationService instance = CategoryMigrationService._();

  bool _ran = false;

  Future<void> runOnce() async {
    if (_ran) return;
    _ran = true;
    try {
      await _migrateCollection('recipes');
      await _migrateCollection('cookbooks');
    } catch (e, st) {
      debugPrint('CategoryMigration: failed $e\n$st');
    }
  }

  Future<void> _migrateCollection(String collection) async {
    final firestore = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>>? last;
    var migrated = 0;
    while (true) {
      Query<Map<String, dynamic>> query = firestore
          .collection(collection)
          .orderBy(FieldPath.documentId)
          .limit(300);
      if (last != null) {
        query = query.startAfterDocument(last);
      }
      final snap = await query.get();
      if (snap.docs.isEmpty) break;
      final batch = firestore.batch();
      for (final doc in snap.docs) {
        final data = doc.data();
        final cats = _extractCategories(
          data['categories'] ?? data['category'] ?? data['tags'],
        );
        if (cats.isEmpty) continue;
        batch.update(doc.reference, {'categories': cats});
        migrated++;
      }
      await batch.commit();
      last = snap.docs.last;
    }
    if (kDebugMode) {
      debugPrint('CategoryMigration: migrated $migrated docs in $collection');
    }
  }

  List<String> _extractCategories(dynamic raw) {
    final result = <String>[];
    void addValue(String value) {
      final key = categoryKeyFromInput(value);
      if (key.isEmpty) return;
      if (result.contains(key)) return;
      result.add(key);
    }

    if (raw is Iterable) {
      for (final item in raw) {
        if (item is String) {
          addValue(item);
        } else if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final key = map['key'] as String? ?? map['id'] as String?;
          final title = map['title'] as String? ?? map['name'] as String?;
          if (key != null && key.isNotEmpty) {
            addValue(key);
          } else if (title != null && title.isNotEmpty) {
            addValue(title);
          }
        }
      }
    } else if (raw is String) {
      addValue(raw);
    }
    return result;
  }
}

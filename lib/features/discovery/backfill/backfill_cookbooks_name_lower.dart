import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Debug-only utility to backfill `nameLower` and `isPublic` on cookbooks.
/// Run manually from a debug entrypoint, then remove or guard behind a flag.
class CookbookNameLowerBackfill {
  CookbookNameLowerBackfill(this._firestore);

  final FirebaseFirestore _firestore;

  String _normalize(String input) =>
      input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  Future<void> run() async {
    if (!kDebugMode) return;
    const pageSize = 400;
    var lastDoc = <String, dynamic>{};
    var updated = 0;
    var scanned = 0;

    Query<Map<String, dynamic>> query = _firestore
        .collection('cookbooks')
        .orderBy(FieldPath.documentId)
        .limit(pageSize);

    while (true) {
      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) break;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        scanned++;
        final data = doc.data();
        final name = (data['title'] ?? data['name'] ?? '').toString();
        final expected = _normalize(name);
        final currentLower = (data['nameLower'] ?? '').toString();
        final hasPublic = data.containsKey('isPublic');
        final needsLower =
            expected.isNotEmpty &&
            (currentLower.isEmpty || currentLower != expected);
        final needsPublic = !hasPublic;
        if (needsLower || needsPublic) {
          final update = <String, dynamic>{};
          if (needsLower) update['nameLower'] = expected;
          if (needsPublic) update['isPublic'] = data['isPublic'] ?? false;
          batch.set(doc.reference, update, SetOptions(merge: true));
          updated++;
        }
      }
      await batch.commit();
      lastDoc = snapshot.docs.last.data();
      if (snapshot.docs.length < pageSize) break;
      query = _firestore
          .collection('cookbooks')
          .orderBy(FieldPath.documentId)
          .startAfterDocument(snapshot.docs.last)
          .limit(pageSize);
    }

    debugPrint(
      '[COOKBOOK_BACKFILL] scanned=$scanned updated=$updated (nameLower/isPublic)',
    );
  }
}

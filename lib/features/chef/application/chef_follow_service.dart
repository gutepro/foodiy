import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:foodiy/core/utils/user_display.dart';

class FollowingChef {
  const FollowingChef({
    required this.chefId,
    required this.displayName,
    required this.avatarUrl,
    this.createdAt,
    this.followersCount = 0,
  });

  final String chefId;
  final String displayName;
  final String avatarUrl;
  final DateTime? createdAt;
  final int followersCount;

  FollowingChef copyWith({
    String? displayName,
    String? avatarUrl,
    int? followersCount,
  }) {
    return FollowingChef(
      chefId: chefId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      followersCount: followersCount ?? this.followersCount,
    );
  }
}

class ChefFollowService {
  ChefFollowService._internal();

  static final ChefFollowService _instance = ChefFollowService._internal();
  static ChefFollowService get instance => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<bool> isFollowing({
    required String currentUid,
    required String chefId,
  }) async {
    if (currentUid.isEmpty || chefId.isEmpty) return false;
    final doc = await _users
        .doc(currentUid)
        .collection('following')
        .doc(chefId)
        .get();
    return doc.exists;
  }

  Future<void> followChef({
    required String currentUid,
    required String chefId,
    String? chefName,
    String? chefAvatarUrl,
    String? userName,
    String? userAvatarUrl,
  }) async {
    if (currentUid.isEmpty || chefId.isEmpty || currentUid == chefId) return;
    try {
      final followRef =
          _users.doc(currentUid).collection('following').doc(chefId);
      final followerRef = _db
          .collection('chefFollowers')
          .doc(chefId)
          .collection('followers')
          .doc(currentUid);
      final chefProfileRef = _users.doc(chefId);

      final existing = await followRef.get();
      if (existing.exists) {
        debugPrint(
          '[CHEF_FOLLOW] already following uid=$currentUid chefId=$chefId',
        );
        return;
      }

      final batch = _db.batch();
      final now = FieldValue.serverTimestamp();
      batch.set(followRef, {
        'createdAt': now,
        if (chefName != null && chefName.isNotEmpty) 'chefName': chefName,
        if (chefAvatarUrl != null && chefAvatarUrl.isNotEmpty)
          'chefAvatar': chefAvatarUrl,
      });
      batch.set(followerRef, {
        'createdAt': now,
        if (userName != null && userName.isNotEmpty) 'userName': userName,
        if (userAvatarUrl != null && userAvatarUrl.isNotEmpty)
          'userAvatar': userAvatarUrl,
      });
      batch.update(
        chefProfileRef,
        {'followersCount': FieldValue.increment(1), 'updatedAt': now},
      );
      await batch.commit();
      debugPrint('[CHEF_FOLLOW] follow success uid=$currentUid chefId=$chefId');
    } catch (e, st) {
      debugPrint('[CHEF_FOLLOW_ERROR] uid=$currentUid chefId=$chefId $e\n$st');
      rethrow;
    }
  }

  Future<void> unfollowChef({
    required String currentUid,
    required String chefId,
  }) async {
    if (currentUid.isEmpty || chefId.isEmpty || currentUid == chefId) return;
    try {
      final followRef =
          _users.doc(currentUid).collection('following').doc(chefId);
      final followerRef = _db
          .collection('chefFollowers')
          .doc(chefId)
          .collection('followers')
          .doc(currentUid);
      final chefProfileRef = _users.doc(chefId);

      final existing = await followRef.get();
      if (!existing.exists) {
        debugPrint(
          '[CHEF_UNFOLLOW] not following uid=$currentUid chefId=$chefId',
        );
        return;
      }

      final chefDoc = await chefProfileRef.get();
      final currentCount = (chefDoc.data()?['followersCount'] as int?) ?? 0;
      final shouldDecrement = currentCount > 0;

      final batch = _db.batch();
      batch.delete(followRef);
      batch.delete(followerRef);
      if (shouldDecrement) {
        batch.update(
          chefProfileRef,
          {
            'followersCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      } else {
        batch.set(
          chefProfileRef,
          {'followersCount': 0, 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
      }
      await batch.commit();
      debugPrint(
        '[CHEF_UNFOLLOW] unfollow success uid=$currentUid chefId=$chefId',
      );
    } catch (e, st) {
      debugPrint(
        '[CHEF_UNFOLLOW_ERROR] uid=$currentUid chefId=$chefId $e\n$st',
      );
      rethrow;
    }
  }

  Stream<List<FollowingChef>> watchFollowingChefs({
    required String uid,
    int limit = 10,
  }) {
    if (uid.isEmpty) return Stream<List<FollowingChef>>.empty();
    final query = _users
        .doc(uid)
        .collection('following')
        .orderBy('createdAt', descending: true)
        .limit(limit);
    return query.snapshots().asyncMap((snap) async {
      final chefs = <FollowingChef>[];
      final missing = <int, String>{};
      for (int i = 0; i < snap.docs.length; i++) {
        final doc = snap.docs[i];
        final data = doc.data();
        final name = resolveUserDisplayName(
          data,
          authFallback: data['chefName'] as String?,
        );
        final avatar = resolveUserAvatar(data) ?? '';
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        chefs.add(
          FollowingChef(
            chefId: doc.id,
            displayName: name,
            avatarUrl: avatar,
            createdAt: createdAt,
          ),
        );
        final storedName = (data['displayName'] as String?) ?? '';
        final storedAvatar =
            (data['chefAvatarUrl'] as String?) ?? (data['photoUrl'] as String?);
        if (storedName.trim().isEmpty || (storedAvatar?.trim().isEmpty ?? true)) {
          missing[i] = doc.id;
        }
      }

      for (final entry in missing.entries) {
        final userSnap = await _users.doc(entry.value).get();
        final data = userSnap.data() ?? {};
        chefs[entry.key] = chefs[entry.key].copyWith(
          displayName: resolveUserDisplayName(
            data,
            chefName: chefs[entry.key].displayName,
          ),
          avatarUrl: resolveUserAvatar(
                data,
                authFallback: chefs[entry.key].avatarUrl,
              ) ??
              chefs[entry.key].avatarUrl,
          followersCount: data['followersCount'] as int? ??
              chefs[entry.key].followersCount,
        );
      }
      return chefs;
    });
  }

  Stream<List<FollowingChef>> watchTopChefs({
    String? excludeUid,
    int limit = 12,
  }) {
    final query = _users
        .where('isChef', isEqualTo: true)
        .orderBy('followersCount', descending: true)
        .limit(limit + 3);
    return query.snapshots().map((snap) {
      final list = snap.docs
          .where((doc) => doc.id != excludeUid)
          .map((doc) {
        final data = doc.data();
        return FollowingChef(
          chefId: doc.id,
          displayName: resolveUserDisplayName(data),
          avatarUrl: resolveUserAvatar(data) ?? '',
          followersCount: data['followersCount'] as int? ?? 0,
        );
      }).take(limit).toList();
      debugPrint(
        '[CHEF_DISCOVER] fetched ${list.length} chefs exclude=$excludeUid',
      );
      return list;
    });
  }
}

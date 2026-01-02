import 'package:cloud_firestore/cloud_firestore.dart';

class UserFollowingService {
  final FirebaseFirestore _db;
  final String _currentUserId;
  final Set<String> _cachedFollowing = <String>{};

  UserFollowingService(this._db, this._currentUserId);

  Set<String> get followingIds => _cachedFollowing;
  bool isFollowing(String uid) => _cachedFollowing.contains(uid);
  void primeCache(Iterable<String> ids) {
    _cachedFollowing
      ..clear()
      ..addAll(ids);
  }

  Future<void> followChef(String chefId) async {
    if (chefId == _currentUserId) return;
    _cachedFollowing.add(chefId);
    await _db.collection('users').doc(_currentUserId).set(
      {
        'followingChefIds': FieldValue.arrayUnion(<String>[chefId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> unfollowChef(String chefId) async {
    _cachedFollowing.remove(chefId);
    await _db.collection('users').doc(_currentUserId).set(
      {
        'followingChefIds': FieldValue.arrayRemove(<String>[chefId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

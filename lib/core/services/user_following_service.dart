import 'package:cloud_firestore/cloud_firestore.dart';

class UserFollowingService {
  final FirebaseFirestore _db;
  final String _currentUserId;

  UserFollowingService(this._db, this._currentUserId);

  Future<void> followChef(String chefId) async {
    if (chefId == _currentUserId) return;
    await _db.collection('users').doc(_currentUserId).set(
      {
        'followingChefIds': FieldValue.arrayUnion(<String>[chefId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> unfollowChef(String chefId) async {
    await _db.collection('users').doc(_currentUserId).set(
      {
        'followingChefIds': FieldValue.arrayRemove(<String>[chefId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_type.dart';
import 'user_following_service.dart';
import 'access_control_service.dart';

class CurrentUserService {
  CurrentUserService._internal();

  static final CurrentUserService _instance = CurrentUserService._internal();
  static CurrentUserService get instance => _instance;

  AppUserProfile? _cachedProfile;
  UserFollowingService? _followingService;

  AppUserProfile? get currentProfile => _cachedProfile;
  UserType get currentUserType => _cachedProfile?.userType ?? UserType.freeUser;
  UserFollowingService? get followingService => _followingService;

  Future<void> refreshFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _cachedProfile = null;
      _followingService = null;
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await docRef.get();

    if (!snap.exists) {
      final now = FieldValue.serverTimestamp();
      await docRef.set({
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'userType': 'homeCook',
        'isChef': false,
        'followingChefIds': <String>[],
        'createdAt': now,
        'updatedAt': now,
        'email': user.email,
        'uid': user.uid,
      });
      final createdSnap = await docRef.get();
      _cachedProfile = AppUserProfile.fromFirestore(
        createdSnap.data() ?? {},
        uid: user.uid,
      );
    } else {
      _cachedProfile = AppUserProfile.fromFirestore(
        snap.data() ?? {},
        uid: user.uid,
      );
    }

    _followingService =
        UserFollowingService(FirebaseFirestore.instance, user.uid);
  }

  void updateUserType(UserType newType) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('CurrentUserService.updateUserType: no Firebase user');
      return;
    }

    SubscriptionPlan newPlan;
    switch (newType) {
      case UserType.freeUser:
        newPlan = SubscriptionPlan.none;
        break;
      case UserType.premiumUser:
        newPlan = SubscriptionPlan.userMonthly; // default for now
        break;
      case UserType.freeChef:
        newPlan = SubscriptionPlan.none;
        break;
      case UserType.premiumChef:
        newPlan = SubscriptionPlan.chefMonthly; // default for now
        break;
    }

    _cachedProfile = AppUserProfile(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      userType: newType,
      userTypeString: _userTypeStringFromEnum(newType),
      isChef: AccessControlService.instance.isChef(newType),
      followingChefIds: _cachedProfile?.followingChefIds ?? const [],
      subscriptionPlan: newPlan,
      createdAt: _cachedProfile?.createdAt,
      updatedAt: DateTime.now(),
    );

    print(
      'CurrentUserService.updateUserType: userType=$newType, subscriptionPlan=$newPlan for uid=${user.uid}',
    );

    // TODO: Persist the new userType and subscriptionPlan to Firestore or custom claims.
  }
}

String _userTypeStringFromEnum(UserType type) {
  switch (type) {
    case UserType.freeUser:
      return 'homeCook';
    case UserType.freeChef:
      return 'chef';
    case UserType.premiumChef:
      return 'premiumChef';
    case UserType.premiumUser:
      return 'homeCook';
  }
}

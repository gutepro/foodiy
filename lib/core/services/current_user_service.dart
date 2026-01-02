import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_type.dart';
import 'subscription_service.dart';
import 'user_following_service.dart';
import 'access_control_service.dart';

class CurrentUserService {
  CurrentUserService._internal();

  static final CurrentUserService _instance = CurrentUserService._internal();
  static CurrentUserService get instance => _instance;

  AppUserProfile? _cachedProfile;
  UserFollowingService? _followingService;
  final ValueNotifier<AppUserProfile?> profileNotifier =
      ValueNotifier<AppUserProfile?>(null);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _profileListener;

  AppUserProfile? get currentProfile => _cachedProfile;
  UserType get currentUserType => _cachedProfile?.userType ?? UserType.freeUser;
  UserFollowingService? get followingService => _followingService;

  void clearCache() {
    _profileListener?.cancel();
    _profileListener = null;
    _cachedProfile = null;
    _followingService = null;
    profileNotifier.value = null;
  }

  Future<void> refreshFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      clearCache();
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await docRef.get();

    if (!snap.exists) {
      final now = FieldValue.serverTimestamp();
      await docRef.set({
        'displayName': user.displayName,
        'displayNameLower': user.displayName?.toLowerCase().trim(),
        'photoUrl': user.photoURL,
        'userType': 'homeCook',
        'tier': 'freeUser',
        'isChef': false,
        'followingChefIds': <String>[],
        'createdAt': now,
        'updatedAt': now,
        'email': user.email,
        'uid': user.uid,
        'subscriptionPlanId': '',
        'subscriptionStatus': 'inactive',
        'onboardingComplete': false,
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
    SubscriptionService.instance.start();

    _followingService =
        UserFollowingService(FirebaseFirestore.instance, user.uid);
    _followingService?.primeCache(_cachedProfile?.followingChefIds ?? const []);

    _listenToProfileChanges(user.uid);
    profileNotifier.value = _cachedProfile;
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
      tierString: _tierStringFromEnum(newType),
      isChef: AccessControlService.instance.isChef(newType),
      followingChefIds: _cachedProfile?.followingChefIds ?? const [],
      subscriptionPlan: newPlan,
      subscriptionStatus:
          newPlan == SubscriptionPlan.none ? 'inactive' : 'active',
      subscriptionPlanId: _planIdFromEnum(newPlan),
      createdAt: _cachedProfile?.createdAt,
      updatedAt: DateTime.now(),
    );

    print(
      'CurrentUserService.updateUserType: userType=$newType, subscriptionPlan=$newPlan for uid=${user.uid}',
    );

    FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {
        'userType': _userTypeStringFromEnum(newType),
        'tier': _tierStringFromEnum(newType),
        'isChef': AccessControlService.instance.isChef(newType),
        'subscriptionPlanId': _planIdFromEnum(newPlan),
        'subscriptionStatus':
            newPlan == SubscriptionPlan.none ? 'inactive' : 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    debugPrint(
      '[USER_ROLE_UPDATE] written role=${_userTypeStringFromEnum(newType)} uid=${user.uid}',
    );
    profileNotifier.value = _cachedProfile;
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return;
    final now = DateTime.now();
    final data = {
      'displayName': trimmed,
      'displayNameLower': trimmed.toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await docRef.set(data, SetOptions(merge: true));

    try {
      await user.updateDisplayName(trimmed);
    } catch (_) {
      // Non-fatal; Firestore remains source of truth.
    }

    if (_cachedProfile != null) {
      _cachedProfile = _cachedProfile!.copyWith(
        displayName: trimmed,
        updatedAt: now,
      );
      profileNotifier.value = _cachedProfile;
    } else {
      final snap = await docRef.get();
      _cachedProfile =
          AppUserProfile.fromFirestore(snap.data() ?? {}, uid: user.uid);
      profileNotifier.value = _cachedProfile;
    }
  }

  void _listenToProfileChanges(String uid) {
    _profileListener?.cancel();
    if (uid.isEmpty) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    _profileListener = docRef.snapshots().listen((snap) {
      if (!snap.exists) return;
      final data = snap.data() ?? {};
      final profile = AppUserProfile.fromFirestore(data, uid: uid);
      _cachedProfile = profile;
      profileNotifier.value = profile;
      SubscriptionService.instance.start();
      debugPrint(
        '[USER_ROLE_STREAM] role=${profile.userTypeString} tier=${profile.tierString} uid=$uid',
      );
    });
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

String _tierStringFromEnum(UserType type) {
  switch (type) {
    case UserType.freeUser:
      return 'freeUser';
    case UserType.premiumUser:
      return 'premiumUser';
    case UserType.freeChef:
      return 'freeChef';
    case UserType.premiumChef:
      return 'premiumChef';
  }
}

String _planIdFromEnum(SubscriptionPlan plan) {
  switch (plan) {
    case SubscriptionPlan.userMonthly:
    case SubscriptionPlan.userYearly:
      return 'premium_user';
    case SubscriptionPlan.chefMonthly:
    case SubscriptionPlan.chefYearly:
      return 'premium_chef';
    case SubscriptionPlan.none:
      return '';
  }
}

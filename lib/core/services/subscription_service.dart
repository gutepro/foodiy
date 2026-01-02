import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'current_user_service.dart';

class SubscriptionService extends ChangeNotifier {
  SubscriptionService._internal();
  static final SubscriptionService instance = SubscriptionService._internal();

  UserType _currentTier = UserType.freeUser;
  String _subscriptionStatus = 'inactive';
  String _subscriptionPlanId = '';
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  StreamSubscription<User?>? _authSub;

  UserType get currentTier => _currentTier;
  String get subscriptionStatus => _subscriptionStatus;
  String get subscriptionPlanId => _subscriptionPlanId;

  bool get adsEnabled =>
      _currentTier == UserType.freeUser || _currentTier == UserType.freeChef;

  int get uploadLimitFreeChef => 10;

  bool canUploadRecipe({required int currentRecipeCount}) {
    if (_currentTier == UserType.premiumChef) return true;
    if (_currentTier == UserType.freeChef) {
      return currentRecipeCount < uploadLimitFreeChef;
    }
    // Non-chefs cannot upload.
    return false;
  }

  int remainingUploads({required int currentRecipeCount}) {
    if (_currentTier != UserType.freeChef) return -1;
    final remaining = uploadLimitFreeChef - currentRecipeCount;
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> start() async {
    _authSub ??= FirebaseAuth.instance.authStateChanges().listen((user) {
      _userSub?.cancel();
      if (user == null) {
        _currentTier = UserType.freeUser;
        _subscriptionStatus = 'inactive';
        _subscriptionPlanId = '';
        notifyListeners();
        return;
      }
      _userSub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snap) {
        final data = snap.data();
        if (data == null) return;
        final tierStr = (data['tier'] as String?) ??
            (data['userType'] as String?) ??
            'freeUser';
        _currentTier = _mapTier(tierStr);
        _subscriptionStatus =
            (data['subscriptionStatus'] as String?) ?? 'inactive';
        _subscriptionPlanId =
            (data['subscriptionPlanId'] as String?) ?? '';
        debugPrint(
          '[SUBSCRIPTION_SERVICE] tier=$_currentTier status=$_subscriptionStatus plan=$_subscriptionPlanId',
        );
        notifyListeners();
      });
    });
  }

  Future<void> simulateUpgrade(UserType tier) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final tierString = _tierString(tier);
    final planId = tier == UserType.premiumChef
        ? 'premium_chef'
        : tier == UserType.premiumUser
            ? 'premium_user'
            : '';
    await doc.set({
      'tier': tierString,
      'userType': tierString == 'homeCook' ? 'homeCook' : tierString,
      'subscriptionStatus':
          planId.isEmpty ? 'inactive' : 'active',
      'subscriptionPlanId': planId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await CurrentUserService.instance.refreshFromFirebase();
  }

  String _tierString(UserType tier) {
    switch (tier) {
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

  UserType _mapTier(String value) {
    switch (value) {
      case 'premiumUser':
        return UserType.premiumUser;
      case 'freeChef':
        return UserType.freeChef;
      case 'premiumChef':
        return UserType.premiumChef;
      case 'homeCook':
      case 'freeUser':
      default:
        return UserType.freeUser;
    }
  }
}

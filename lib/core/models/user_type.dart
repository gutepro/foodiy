enum UserType {
  freeUser,
  premiumUser,
  freeChef,
  premiumChef,
}

enum SubscriptionPlan {
  none,
  userMonthly,
  userYearly,
  chefMonthly,
  chefYearly,
}

class AppUserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? firstName;
  final String? lastName;
  final String? websiteUrl;
  final String userTypeString;
  final bool isChef;
  final List<String> followingChefIds;
  final int followersCount;
  final String? chefBio;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserType userType;
  final SubscriptionPlan subscriptionPlan;
  final String subscriptionStatus;
  final String subscriptionPlanId;
  final String tierString;
  final bool onboardingComplete;

  const AppUserProfile({
    required this.uid,
    required this.userType,
    required this.userTypeString,
    required this.tierString,
    required this.isChef,
    required this.followingChefIds,
    this.chefBio = '',
    this.firstName = '',
    this.lastName = '',
    this.websiteUrl = '',
    this.email,
    this.displayName,
    this.photoUrl,
    this.subscriptionPlan = SubscriptionPlan.none,
    this.subscriptionStatus = 'inactive',
    this.subscriptionPlanId = '',
    this.onboardingComplete = false,
    this.createdAt,
    this.updatedAt,
    this.followersCount = 0,
  });

  factory AppUserProfile.fromFirestore(
    Map<String, dynamic> data, {
    required String uid,
  }) {
    final userTypeStr = (data['userType'] as String?) ?? 'homeCook';
    final tierStr = (data['tier'] as String?) ?? userTypeStr;
    final userTypeEnum = _mapUserTypeString(userTypeStr);
    final planId = (data['subscriptionPlanId'] as String?) ?? '';
    final status = (data['subscriptionStatus'] as String?) ?? 'inactive';
    return AppUserProfile(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      websiteUrl: data['websiteUrl'] as String? ?? '',
      userType: userTypeEnum,
      userTypeString: userTypeStr,
      tierString: tierStr,
      isChef: data['isChef'] as bool? ?? false,
      followingChefIds:
          (data['followingChefIds'] as List<dynamic>?)?.cast<String>() ??
              const [],
      chefBio: data['chefBio'] as String? ?? '',
      followersCount: data['followersCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate(),
      subscriptionPlan: _mapPlan(planId),
      subscriptionStatus: status,
      subscriptionPlanId: planId,
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
    );
  }

  AppUserProfile copyWith({
    String? displayName,
    String? photoUrl,
    List<String>? followingChefIds,
    DateTime? updatedAt,
    bool? onboardingComplete,
  }) {
    return AppUserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      firstName: firstName,
      lastName: lastName,
      websiteUrl: websiteUrl,
      userType: userType,
      userTypeString: userTypeString,
      tierString: tierString,
      isChef: isChef,
      followingChefIds: followingChefIds ?? this.followingChefIds,
      chefBio: chefBio,
      followersCount: followersCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subscriptionPlan: subscriptionPlan,
      subscriptionStatus: subscriptionStatus,
      subscriptionPlanId: subscriptionPlanId,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'firstName': firstName,
      'lastName': lastName,
      'websiteUrl': websiteUrl,
      'userType': userTypeString,
      'tier': tierString,
      'isChef': isChef,
      'followingChefIds': followingChefIds,
      'chefBio': chefBio,
      'followersCount': followersCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'subscriptionPlanId': subscriptionPlanId,
      'subscriptionStatus': subscriptionStatus,
      'onboardingComplete': onboardingComplete,
    };
  }
}

// TODO: Load AppUserProfile from Firestore or custom Firebase claims instead of hard coded defaults.

UserType _mapUserTypeString(String value) {
  switch (value) {
    case 'premiumUser':
      return UserType.premiumUser;
    case 'freeChef':
    case 'chef':
      return UserType.freeChef;
    case 'premiumChef':
      return UserType.premiumChef;
    case 'homeCook':
    default:
      return UserType.freeUser;
  }
}

SubscriptionPlan _mapPlan(String value) {
  switch (value) {
    case 'premium_user':
      return SubscriptionPlan.userMonthly;
    case 'premium_chef':
      return SubscriptionPlan.chefMonthly;
    default:
      return SubscriptionPlan.none;
  }
}

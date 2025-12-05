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
  final String? chefBio;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserType userType;
  final SubscriptionPlan subscriptionPlan;

  const AppUserProfile({
    required this.uid,
    required this.userType,
    required this.userTypeString,
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
    this.createdAt,
    this.updatedAt,
  });

  factory AppUserProfile.fromFirestore(
    Map<String, dynamic> data, {
    required String uid,
  }) {
    final userTypeStr = (data['userType'] as String?) ?? 'homeCook';
    final userTypeEnum = _mapUserTypeString(userTypeStr);
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
      isChef: data['isChef'] as bool? ?? false,
      followingChefIds:
          (data['followingChefIds'] as List<dynamic>?)?.cast<String>() ??
              const [],
      chefBio: data['chefBio'] as String? ?? '',
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate(),
      subscriptionPlan: SubscriptionPlan.none,
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
      'isChef': isChef,
      'followingChefIds': followingChefIds,
      'chefBio': chefBio,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// TODO: Load AppUserProfile from Firestore or custom Firebase claims instead of hard coded defaults.

UserType _mapUserTypeString(String value) {
  switch (value) {
    case 'chef':
      return UserType.freeChef;
    case 'premiumChef':
      return UserType.premiumChef;
    case 'homeCook':
    default:
      return UserType.freeUser;
  }
}

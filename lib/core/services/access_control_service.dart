import 'package:foodiy/core/models/user_type.dart';

class AccessControlService {
  AccessControlService._internal();

  static final AccessControlService _instance = AccessControlService._internal();
  static AccessControlService get instance => _instance;

  bool canUploadRecipes(UserType type) {
    return type == UserType.freeChef || type == UserType.premiumChef;
  }

  bool hasUploadLimit(UserType type) {
    return type == UserType.freeChef;
  }

  bool canCreatePersonalPlaylists(UserType type) {
    return type == UserType.premiumUser || type == UserType.premiumChef;
  }

  bool canCreatePublicPlaylists(UserType type) {
    return type == UserType.premiumChef;
  }

  bool hasNoAds(UserType type) {
    return type == UserType.premiumUser || type == UserType.premiumChef;
  }

  bool canViewStats(UserType type) {
    return type == UserType.premiumChef;
  }

  bool isChef(UserType type) {
    return type == UserType.freeChef || type == UserType.premiumChef;
  }
}

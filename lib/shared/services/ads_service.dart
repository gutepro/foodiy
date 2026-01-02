import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:foodiy/core/models/user_type.dart';
import 'package:foodiy/core/services/subscription_service.dart';

class AdsService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    debugPrint(
      '[ADS_INIT] platform=${Platform.operatingSystem} success=true adSdk=google_mobile_ads',
    );
  }

  static bool adsEnabled(UserType tier) {
    return SubscriptionService.instance.adsEnabled;
  }

  static String get bannerAdUnitIdTest {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return 'ca-app-pub-3940256099942544/6300978111';
  }
}

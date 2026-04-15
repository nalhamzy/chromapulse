import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// AdMob unit IDs. Uses Google's official test IDs until real ones are provided.
///
/// Replace the non-debug branch values with your real unit IDs before release.
/// Real AdMob app IDs also need to go into:
///   - android/app/src/main/AndroidManifest.xml (`com.google.android.gms.ads.APPLICATION_ID`)
///   - ios/Runner/Info.plist (`GADApplicationIdentifier`)
class AdIds {
  AdIds._();

  // Google's official test unit IDs — safe to ship in debug builds.
  static const _testBannerAndroid       = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos           = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos     = 'ca-app-pub-3940256099942544/4411468910';
  static const _testRewardedAndroid     = 'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIos         = 'ca-app-pub-3940256099942544/1712485313';

  // TODO(chromapulse): replace with real unit IDs before shipping to production.
  static const _prodBannerAndroid       = _testBannerAndroid;
  static const _prodBannerIos           = _testBannerIos;
  static const _prodInterstitialAndroid = _testInterstitialAndroid;
  static const _prodInterstitialIos     = _testInterstitialIos;
  static const _prodRewardedAndroid     = _testRewardedAndroid;
  static const _prodRewardedIos         = _testRewardedIos;

  static String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS ? _testBannerIos : _testBannerAndroid;
    }
    return Platform.isIOS ? _prodBannerIos : _prodBannerAndroid;
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS ? _testInterstitialIos : _testInterstitialAndroid;
    }
    return Platform.isIOS ? _prodInterstitialIos : _prodInterstitialAndroid;
  }

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS ? _testRewardedIos : _testRewardedAndroid;
    }
    return Platform.isIOS ? _prodRewardedIos : _prodRewardedAndroid;
  }
}

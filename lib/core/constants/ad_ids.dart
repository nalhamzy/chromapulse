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
  static const _prodBannerAndroid       = 'ca-app-pub-4401199263287951/4525098783';
  static const _prodBannerIos           = 'ca-app-pub-4401199263287951/1637091897';
  static const _prodInterstitialAndroid = 'ca-app-pub-4401199263287951/7929991323';
  static const _prodInterstitialIos     = 'ca-app-pub-4401199263287951/4079422403';
  static const _prodRewardedAndroid     = 'ca-app-pub-4401199263287951/6921208163';
  static const _prodRewardedIos         = 'ca-app-pub-4401199263287951/8177403334';

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

import 'package:flutter/widgets.dart';

/// Web stub — all methods are no-ops so the app compiles for Chrome without
/// pulling in google_mobile_ads (which doesn't support web).
class AdService {
  bool get initialized => false;
  bool get hasRewardedAd => false;

  Future<void> initialize() async {}

  Widget? buildBanner() => null;

  Future<void> maybeShowInterstitial({void Function()? onDismissed}) async {
    onDismissed?.call();
  }

  Future<void> showRewardedAd({
    required void Function() onRewarded,
    void Function()? onUnavailable,
  }) async {
    onUnavailable?.call();
  }

  void dispose() {}
}

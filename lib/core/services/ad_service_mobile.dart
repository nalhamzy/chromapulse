import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chromapulse/core/constants/ad_ids.dart';

/// Mobile implementation of AdService. The web stub exposes the same public
/// surface with no-op methods.
class AdService {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _initialized = false;

  // Frequency caps.
  static const Duration _minInterstitialInterval = Duration(minutes: 2);
  static const int _gamesPerInterstitial = 3;
  DateTime? _lastInterstitialAt;
  int _gameOverCount = 0;

  bool get initialized => _initialized;
  bool get hasRewardedAd => _rewardedAd != null;

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();

    // ChromaPulse is NOT targeted at children — use standard content rating.
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.pg,
      ),
    );

    _initialized = true;
    _loadBanner();
    _loadInterstitial();
    _loadRewarded();
  }

  /// Returns a widget to embed the banner, or null if no banner is available.
  Widget? buildBanner() {
    final ad = _bannerAd;
    if (ad == null) return null;
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }

  // ── Banner ────────────────────────────────────────────────────────────

  void _loadBanner() {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: AdIds.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => debugPrint('[AdService] Banner loaded'),
        onAdFailedToLoad: (ad, err) {
          debugPrint('[AdService] Banner failed: ${err.message}');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  // ── Interstitial ──────────────────────────────────────────────────────

  Future<void> _loadInterstitial() async {
    await InterstitialAd.load(
      adUnitId: AdIds.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  Future<void> maybeShowInterstitial({void Function()? onDismissed}) async {
    _gameOverCount++;
    final capByCount = _gameOverCount % _gamesPerInterstitial != 0;
    final capByTime = _lastInterstitialAt != null &&
        DateTime.now().difference(_lastInterstitialAt!) <
            _minInterstitialInterval;
    if (capByCount || capByTime || _interstitialAd == null) {
      onDismissed?.call();
      return;
    }
    _lastInterstitialAt = DateTime.now();

    // Single-fire guard — guarantees the result screen navigation runs
    // exactly once even if both the dismiss and failure callbacks arrive
    // (or the watchdog beats them to it).
    bool resolved = false;
    Timer? watchdog;
    void resolveOnce() {
      if (resolved) return;
      resolved = true;
      watchdog?.cancel();
      onDismissed?.call();
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
        resolveOnce();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
        resolveOnce();
      },
    );

    // Safety watchdog — interstitials are normally 5–30 s and have a close
    // button enforced by AdMob policy. If neither dismiss nor failure
    // callback fires within 90 s (bad network, SDK bug, misbehaving
    // creative), force-progress so the player is never stranded behind a
    // stuck ad. The ad object itself survives — when the user finally taps
    // X the SDK callback fires, [resolveOnce] is a no-op, and the ad is
    // disposed normally.
    watchdog = Timer(const Duration(seconds: 90), resolveOnce);

    try {
      await _interstitialAd!.show();
    } catch (_) {
      // .show() can throw if the ad object is already disposed. Recover by
      // routing through the same single-fire path so we never hang.
      resolveOnce();
    }
  }

  // ── Rewarded ──────────────────────────────────────────────────────────

  Future<void> _loadRewarded() async {
    await RewardedAd.load(
      adUnitId: AdIds.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  Future<void> showRewardedAd({
    required void Function() onRewarded,
    void Function()? onUnavailable,
  }) async {
    if (_rewardedAd == null) {
      onUnavailable?.call();
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewarded();
        onUnavailable?.call();
      },
    );
    await _rewardedAd!.show(
      onUserEarnedReward: (_, _) => onRewarded(),
    );
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}

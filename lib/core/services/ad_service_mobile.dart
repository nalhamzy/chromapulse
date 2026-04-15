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
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
        onDismissed?.call();
      },
    );
    await _interstitialAd!.show();
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

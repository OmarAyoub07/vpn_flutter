import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/app_config.dart';

class AdService {
  final AppConfigResponse config;

  DateTime? _lastAdShownAt;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  NativeAd? _nativeAd;
  bool _nativeAdLoaded = false;
  bool _rewardedAdInProgress = false;

  /// Called when native ad load state changes so the UI can rebuild.
  VoidCallback? onNativeAdStateChanged;

  AdService({required this.config});

  /// Returns true only on Android and iOS where AdMob is supported.
  static bool get isSupported {
    if (kIsWeb) return false;
    // TODO: Re-enable iOS ads after upgrading google_mobile_ads to 7.x
    return Platform.isAndroid;
  }

  Timer? _randomAdTimer;

  void initialize() {
    if (!isSupported) return;
    try {
      MobileAds.instance.initialize();
      _preloadAds();
      _startRandomAdTimer();
    } catch (e) {
      debugPrint('AdService: initialization failed: $e');
    }
  }

  void _preloadAds() {
    if (config.rewardedAdsEnabled) _loadRewardedAd();
    if (config.interstitialAdsEnabled) _loadInterstitialAd();
    if (config.nativeAdsEnabled) _loadNativeAd();
  }

  /// Periodically attempt to show interstitials at random intervals.
  /// The timer fires every [ad_min_gap_seconds] and has a random chance
  /// of showing the ad, making it truly unpredictable.
  void _startRandomAdTimer() {
    if (!config.interstitialAdsEnabled) return;
    final gapSeconds = config.adMinGapSeconds;
    // Check every gap period; show with 50% probability each tick
    _randomAdTimer = Timer.periodic(
      Duration(seconds: gapSeconds),
      (_) => showInterstitialIfEligible(),
    );
  }

  // ── Rewarded Ads ──

  void _loadRewardedAd() {
    if (!isSupported) return;
    try {
      RewardedAd.load(
        adUnitId: config.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) => _rewardedAd = ad,
          onAdFailedToLoad: (error) => _rewardedAd = null,
        ),
      );
    } catch (_) {}
  }

  /// Show [count] sequential rewarded ads. Returns true if all were completed.
  /// On unsupported platforms, returns true immediately (skip ads).
  /// [onProgress] is called with (completedCount, totalCount) after each ad.
  Future<bool> showRewardedAds(
    int count, {
    void Function(int completed, int total)? onProgress,
  }) async {
    if (!isSupported) return true;

    _rewardedAdInProgress = true;
    try {
      for (int i = 0; i < count; i++) {
        if (_rewardedAd == null) {
          await _waitForRewardedAd();
          if (_rewardedAd == null) return false;
        }

        final completed = await _showSingleRewardedAd();
        if (!completed) return false;

        onProgress?.call(i + 1, count);

        if (i < count - 1) {
          _loadRewardedAd();
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
      _lastAdShownAt = DateTime.now();
      _loadRewardedAd();
      return true;
    } finally {
      _rewardedAdInProgress = false;
    }
  }

  Future<void> _waitForRewardedAd() async {
    _loadRewardedAd();
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_rewardedAd != null) return;
    }
  }

  Future<bool> _showSingleRewardedAd() async {
    final completer = Completer<bool>();
    final ad = _rewardedAd!;
    _rewardedAd = null;
    bool rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    ad.show(onUserEarnedReward: (_, reward) {
      rewarded = true;
    });

    return completer.future;
  }

  // ── Interstitial Ads ──

  void _loadInterstitialAd() {
    if (!isSupported) return;
    try {
      InterstitialAd.load(
        adUnitId: config.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
    } catch (_) {}
  }

  final Random _random = Random();

  /// Number of eligible calls skipped since last shown ad.
  int _skippedCount = 0;

  /// Show interstitial randomly, respecting the minimum gap.
  ///
  /// After the gap is satisfied, the ad has a random chance of showing.
  /// The probability increases with each skipped opportunity so the user
  /// always sees an ad eventually, but never knows exactly when.
  ///   - 1st eligible call after gap: 40% chance
  ///   - 2nd: 60%
  ///   - 3rd: 80%
  ///   - 4th+: guaranteed
  void showInterstitialIfEligible() {
    if (!isSupported) return;
    if (!config.interstitialAdsEnabled) return;
    if (_rewardedAdInProgress) return;
    if (!_isGapSatisfied()) return;
    if (_interstitialAd == null) return;

    // Escalating probability: 0.4, 0.6, 0.8, 1.0
    final probability = (0.4 + _skippedCount * 0.2).clamp(0.0, 1.0);
    if (_random.nextDouble() > probability) {
      _skippedCount++;
      return;
    }

    _skippedCount = 0;
    final ad = _interstitialAd!;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitialAd();
      },
    );

    ad.show();
    _lastAdShownAt = DateTime.now();
  }

  bool _isGapSatisfied() {
    if (_lastAdShownAt == null) return true;
    return DateTime.now().difference(_lastAdShownAt!).inSeconds >=
        config.adMinGapSeconds;
  }

  // ── Native Ads ──

  bool get isNativeAdLoaded => _nativeAdLoaded;

  void _loadNativeAd() {
    if (!isSupported) return;
    try {
      _nativeAd = NativeAd(
        adUnitId: config.nativeAdUnitId,
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            _nativeAdLoaded = true;
            onNativeAdStateChanged?.call();
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _nativeAd = null;
            _nativeAdLoaded = false;
            onNativeAdStateChanged?.call();
          },
        ),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.small,
        ),
      )..load();
    } catch (_) {}
  }

  /// Returns a native ad widget if loaded, or null.
  Widget? getNativeAdWidget() {
    if (!isSupported) return null;
    if (!config.nativeAdsEnabled || !_nativeAdLoaded || _nativeAd == null) {
      return null;
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 120,
        minWidth: 120,
      ),
      child: SizedBox(
        width: double.infinity,
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }

  void dispose() {
    _randomAdTimer?.cancel();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    _nativeAd?.dispose();
  }
}

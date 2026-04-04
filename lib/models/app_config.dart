import 'dart:io' show Platform;
import 'rewarded_ad_tier.dart';

class AppConfigResponse {
  final int initialRemainingSeconds;
  final String dns;
  final int maxAttachmentsPerFeedback;
  final int adMinGapSeconds;
  final int referralRewardSeconds;

  final String rewardedAdUnitId;
  final String interstitialAdUnitId;
  final String nativeAdUnitId;
  final String bannerAdUnitId;

  final bool rewardedAdsEnabled;
  final bool interstitialAdsEnabled;
  final bool nativeAdsEnabled;
  final bool bannerAdsEnabled;

  final List<RewardedAdTier> rewardedAdTiers;

  final String googlePlayUrl;
  final String appleStoreUrl;
  final String microsoftStoreUrl;

  AppConfigResponse({
    required this.initialRemainingSeconds,
    required this.dns,
    required this.maxAttachmentsPerFeedback,
    required this.adMinGapSeconds,
    required this.referralRewardSeconds,
    required this.rewardedAdUnitId,
    required this.interstitialAdUnitId,
    required this.nativeAdUnitId,
    required this.bannerAdUnitId,
    required this.rewardedAdsEnabled,
    required this.interstitialAdsEnabled,
    required this.nativeAdsEnabled,
    required this.bannerAdsEnabled,
    required this.rewardedAdTiers,
    required this.googlePlayUrl,
    required this.appleStoreUrl,
    required this.microsoftStoreUrl,
  });

  /// Returns the store URL for the current platform.
  String get storeUrl {
    if (Platform.isIOS || Platform.isMacOS) return appleStoreUrl;
    if (Platform.isWindows) return microsoftStoreUrl;
    return googlePlayUrl; // Android and fallback
  }

  factory AppConfigResponse.fromJson(Map<String, dynamic> json) {
    return AppConfigResponse(
      initialRemainingSeconds: json['initial_remaining_seconds'] ?? 60,
      dns: json['dns'] ?? '1.1.1.3, 1.0.0.3',
      maxAttachmentsPerFeedback: json['max_attachments_per_feedback'] ?? 2,
      adMinGapSeconds: json['ad_min_gap_seconds'] ?? 180,
      referralRewardSeconds: json['referral_reward_seconds'] ?? 3600,
      rewardedAdUnitId: json['rewarded_ad_unit_id'] ?? '',
      interstitialAdUnitId: json['interstitial_ad_unit_id'] ?? '',
      nativeAdUnitId: json['native_ad_unit_id'] ?? '',
      bannerAdUnitId: json['banner_ad_unit_id'] ?? '',
      rewardedAdsEnabled: json['rewarded_ads_enabled'] ?? true,
      interstitialAdsEnabled: json['interstitial_ads_enabled'] ?? true,
      nativeAdsEnabled: json['native_ads_enabled'] ?? true,
      bannerAdsEnabled: json['banner_ads_enabled'] ?? true,
      rewardedAdTiers: (json['rewarded_ad_tiers'] as List<dynamic>?)
              ?.map((t) => RewardedAdTier.fromJson(t))
              .toList() ??
          [],
      googlePlayUrl: json['google_play_url'] ?? '',
      appleStoreUrl: json['apple_store_url'] ?? '',
      microsoftStoreUrl: json['microsoft_store_url'] ?? '',
    );
  }
}

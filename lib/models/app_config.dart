import 'dart:io' show Platform;
import 'rewarded_ad_tier.dart';

class AppConfigResponse {
  final int initialRemainingSeconds;
  final String dns;
  final int maxAttachmentsPerFeedback;
  final int adMinGapSeconds;
  final int referralRewardSeconds;

  final String androidRewardedAdUnitId;
  final String androidInterstitialAdUnitId;
  final String androidNativeAdUnitId;
  final String androidBannerAdUnitId;
  final String iosRewardedAdUnitId;
  final String iosInterstitialAdUnitId;
  final String iosNativeAdUnitId;
  final String iosBannerAdUnitId;

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
    required this.androidRewardedAdUnitId,
    required this.androidInterstitialAdUnitId,
    required this.androidNativeAdUnitId,
    required this.androidBannerAdUnitId,
    required this.iosRewardedAdUnitId,
    required this.iosInterstitialAdUnitId,
    required this.iosNativeAdUnitId,
    required this.iosBannerAdUnitId,
    required this.rewardedAdsEnabled,
    required this.interstitialAdsEnabled,
    required this.nativeAdsEnabled,
    required this.bannerAdsEnabled,
    required this.rewardedAdTiers,
    required this.googlePlayUrl,
    required this.appleStoreUrl,
    required this.microsoftStoreUrl,
  });

  /// Returns the ad unit IDs for the current platform.
  String get rewardedAdUnitId =>
      Platform.isIOS ? iosRewardedAdUnitId : androidRewardedAdUnitId;
  String get interstitialAdUnitId =>
      Platform.isIOS ? iosInterstitialAdUnitId : androidInterstitialAdUnitId;
  String get nativeAdUnitId =>
      Platform.isIOS ? iosNativeAdUnitId : androidNativeAdUnitId;
  String get bannerAdUnitId =>
      Platform.isIOS ? iosBannerAdUnitId : androidBannerAdUnitId;

  /// Returns the store URL for the current platform.
  String get storeUrl {
    if (Platform.isIOS || Platform.isMacOS) return appleStoreUrl;
    if (Platform.isWindows) return microsoftStoreUrl;
    return googlePlayUrl; // Android and fallback
  }

  /// Returns a deep link that opens the store's rating/review dialog directly.
  String get ratingUrl {
    if (Platform.isAndroid) {
      // market:// scheme opens the Play Store app directly.
      final uri = Uri.tryParse(googlePlayUrl);
      final id = uri?.queryParameters['id'];
      if (id != null) return 'market://details?id=$id';
      return googlePlayUrl;
    }
    if (Platform.isIOS || Platform.isMacOS) {
      // action=write-review opens the review dialog.
      final uri = Uri.tryParse(appleStoreUrl);
      if (uri != null) {
        return uri.replace(queryParameters: {
          ...uri.queryParameters,
          'action': 'write-review',
        }).toString();
      }
      return appleStoreUrl;
    }
    if (Platform.isWindows) {
      // ms-windows-store://review/ opens the review dialog.
      final uri = Uri.tryParse(microsoftStoreUrl);
      final segments = uri?.pathSegments ?? [];
      // Extract product ID from URLs like https://apps.microsoft.com/detail/{id}
      final productId = segments.isNotEmpty ? segments.last : '';
      if (productId.isNotEmpty) {
        return 'ms-windows-store://review/?ProductId=$productId';
      }
      return microsoftStoreUrl;
    }
    return storeUrl;
  }

  factory AppConfigResponse.fromJson(Map<String, dynamic> json) {
    return AppConfigResponse(
      initialRemainingSeconds: json['initial_remaining_seconds'] ?? 60,
      dns: json['dns'] ?? '1.1.1.3, 1.0.0.3',
      maxAttachmentsPerFeedback: json['max_attachments_per_feedback'] ?? 2,
      adMinGapSeconds: json['ad_min_gap_seconds'] ?? 180,
      referralRewardSeconds: json['referral_reward_seconds'] ?? 3600,
      androidRewardedAdUnitId: json['android_rewarded_ad_unit_id'] ?? '',
      androidInterstitialAdUnitId: json['android_interstitial_ad_unit_id'] ?? '',
      androidNativeAdUnitId: json['android_native_ad_unit_id'] ?? '',
      androidBannerAdUnitId: json['android_banner_ad_unit_id'] ?? '',
      iosRewardedAdUnitId: json['ios_rewarded_ad_unit_id'] ?? '',
      iosInterstitialAdUnitId: json['ios_interstitial_ad_unit_id'] ?? '',
      iosNativeAdUnitId: json['ios_native_ad_unit_id'] ?? '',
      iosBannerAdUnitId: json['ios_banner_ad_unit_id'] ?? '',
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

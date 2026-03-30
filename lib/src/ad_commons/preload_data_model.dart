import '../ad_internal.dart';

/// Configuration data for all ad-related settings.
class AdConfigData {
  /// IDs for various ad formats.
  final AdIDS? adIDs;

  /// Controls ad display counters.
  final AdCounter? adCounter;

  /// Toggles for showing/hiding different types of ads.
  final AdFlag? adFlag;

  /// Constructor for [AdConfigData].
  AdConfigData({this.adIDs, this.adCounter, this.adFlag});
}

/// Contains Ad Unit IDs for different ad types.
class AdIDS {
  /// App open ad ID.
  final String? appOpenId;

  /// Banner ad ID.
  final String? bannerId;

  /// Default Native ad ID.
  final String? nativeId;

  /// Interstitial ad ID.
  final String? interstitialId;

  /// Rewarded ad ID.
  final String? rewardedId;

  /// Custom native ad factory configurations.
  final List<NativeAdFactoryConfig>? customFactories;

  /// Constructor for [AdIDS].
  AdIDS({
    this.appOpenId,
    this.bannerId,
    this.nativeId,
    this.interstitialId,
    this.rewardedId,
    this.customFactories,
  });
}

/// Configuration for a custom native ad factory.
class NativeAdFactoryConfig {
  /// Unique identifier for this factory.
  final String factoryId;

  /// Optional ad unit ID specifically for this factory.
  final String? adUnitId;

  /// Whether this custom ad is rendered using the builder pattern (PlatformView).
  final bool isBuilder;

  /// Constructor for [NativeAdFactoryConfig].
  NativeAdFactoryConfig({
    required this.factoryId,
    this.adUnitId,
    this.isBuilder = true,
  });

  /// Converts this configuration to a JSON map.
  Map<String, dynamic> toJson() => {
        'factoryId': factoryId,
        'isBuilder': isBuilder,
      };
}

/// Represents the raw assets of a native ad, extracted on the native side.
class NativeAdAssets {
  /// Unique identifier for the factory that loaded this ad.
  final String? factoryId;

  /// The headline of the ad.
  final String? headline;

  /// The body text of the ad.
  final String? body;

  /// The text for the call to action button.
  final String? callToAction;

  /// The name of the advertiser.
  final String? advertiser;

  /// The store name (e.g., App Store, Play Store).
  final String? store;

  /// The price of the app or item.
  final String? price;

  /// The star rating (0 to 5).
  final double? rating;

  /// The raw bytes of the ad's icon image.
  final Uint8List? iconBytes;

  /// A list of image URLs from the ad.
  final List<String> imageUrls;

  /// Whether the ad contains video content.
  final bool hasVideo;

  /// The duration of the video content in seconds.
  final double? duration;

  /// The aspect ratio of the media content.
  final double? aspectRatio;

  /// Constructor for [NativeAdAssets].
  NativeAdAssets({
    this.factoryId,
    this.headline,
    this.body,
    this.callToAction,
    this.advertiser,
    this.store,
    this.price,
    this.rating,
    this.iconBytes,
    this.imageUrls = const [],
    this.hasVideo = false,
    this.duration,
    this.aspectRatio,
  });

  /// Creates a [NativeAdAssets] instance from a platform-provided map.
  factory NativeAdAssets.fromMap(Map<dynamic, dynamic> map) {
    return NativeAdAssets(
      factoryId: map['factoryId'] as String?,
      headline: map['headline'] as String?,
      body: map['body'] as String?,
      callToAction: map['callToAction'] as String?,
      advertiser: map['advertiser'] as String?,
      store: map['store'] as String?,
      price: map['price'] as String?,
      rating: (map['rating'] as num?)?.toDouble(),
      iconBytes: map['iconBytes'] as Uint8List?,
      imageUrls: map['images'] != null ? List<String>.from(map['images']) : const [],
      hasVideo: map['hasVideo'] as bool? ?? false,
      duration: (map['duration'] as num?)?.toDouble(),
      aspectRatio: (map['aspectRatio'] as num?)?.toDouble(),
    );
  }
}


/// Controls the display frequency of ads using counters.
class AdCounter {
  /// Number of times to show interstitial ads.
  final int? interstitialCounter;

  /// Number of times to show rewarded ads.
  final int? rewardedCounter;

  /// Constructor for [AdCounter].
  AdCounter({
    this.interstitialCounter,
    this.rewardedCounter,
  });
}

/// Flags to enable/disable various ad types.
class AdFlag {
  /// Master flag to show/hide all ads.
  final bool? showAd;

  /// Show banner ads.
  final bool? showBanner;

  /// Show interstitial ads.
  final bool? showInterstitial;

  /// Show splash screen ad.
  final bool? showSplashAd;

  /// Show open app ad.
  final bool? showOpenApp;

  /// Show rewarded ad.
  final bool? showRewarded;

  /// Constructor for [AdFlag].
  AdFlag({
    this.showAd,
    this.showBanner,
    this.showInterstitial,
    this.showSplashAd,
    this.showOpenApp,
    this.showRewarded,
  });
}

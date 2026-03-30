import 'ad_internal.dart';

/// Singleton wrapper class to manage ad interactions via [AdManager].
class PreloadGoogleAds {
  /// Private constructor for singleton pattern
  PreloadGoogleAds._privateConstructor();

  /// Singleton instance
  static final PreloadGoogleAds instance =
      PreloadGoogleAds._privateConstructor();

  /// Reference to the internal AdManager instance
  final AdManager _adManager = AdManager.instance;

  /// Initializes the ad system with optional [adConfig].
  /// Loads and prepares ads if configuration allows.
  Future<void> initialize({AdConfigData? adConfigData}) async {
    await AdManager.instance.initialize(adConfigData);
  }

  /// Sets the splash ad callback.
  /// This should be set before calling initialize if you want a callback
  /// when splash ad loads or fails.
  void setSplashAdCallback(Function(AppOpenAd? ad, AdError? error) callback) {
    _adManager.setSplashAdCallback(callback);
  }


  /// Displays a fully customisable native ad using the builder pattern
  /// with a registered factory ID.
  ///
  /// This creates a [CustomNativeAdView] that loads ads via native
  /// PlatformViews while rendering the UI entirely in Flutter.
  /// Register a factory via [NativeAdFactoryConfig] during initialization,
  /// then pass that factory's ID here.
  ///
  /// See [CustomNativeAdView] for full documentation and examples.
  Widget showBuilderNativeAd({
    String? factoryId,
    String? adUnitId,
    NativeAdSize size = NativeAdSize.custom,
    required NativeAdBuilder builder,
    Widget? fallback,
    VoidCallback? onAdLoaded,
    void Function(String code, String message)? onAdFailedToLoad,
    VoidCallback? onAdClicked,
    VoidCallback? onAdImpression,
    VoidCallback? onAdOpened,
    VoidCallback? onAdClosed,
  }) {
    return CustomNativeAdView(
      factoryId: factoryId,
      adUnitId: adUnitId,
      size: size,
      builder: builder,
      fallback: fallback,
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
      onAdClicked: onAdClicked,
      onAdImpression: onAdImpression,
      onAdOpened: onAdOpened,
      onAdClosed: onAdClosed,
    );
  }

  /// Displays the open app ad (not the splash ad).
  void showOpenApp() {
    return _adManager.showOpenApp();
  }

  /// Displays a banner ad if available.
  Widget showBannerAd() {
    return _adManager.showBannerAd();
  }

  /// Shows the ad counter, typically for debugging or development.
  /// Defaults to showing the counter.
  Widget showAdCounter({bool? showCounter}) {
    return _adManager.showAdCounter(showCounter: showCounter);
  }

  /// Displays an interstitial ad.
  /// Returns the [InterstitialAd] or [AdError] through the [callBack].
  void showInterstitialAd({
    required Function(InterstitialAd? ad, AdError? error) callBack,
  }) {
    return _adManager.showInterstitialAd(callBack: callBack);
  }

  /// Displays a rewarded ad.
  ///
  /// Provide a [callBack] to receive the [RewardedAd] or [AdError] when the ad is shown or fails.
  /// The [onReward] function is called when the user successfully earns the reward.
  void showRewardedAd({
    required void Function(RewardedAd? ad, AdError? error) callBack,
    required void Function(AdWithoutView ad, RewardItem reward) onReward,
  }) {
    return _adManager.showRewardedAd(callBack: callBack, onReward: onReward);
  }


  /// Manually triggers preloading for a builder-pattern native ad on the native side.
  Future<void> preloadBuilderAd({
    required String adUnitId,
    required String factoryId,
  }) async {
    return _adManager.preloadBuilderAd(adUnitId: adUnitId, factoryId: factoryId);
  }
}

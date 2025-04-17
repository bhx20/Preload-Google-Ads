import '../preload_google_ads.dart';

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
  Future<void> initialize({AdConfigData? adConfig}) async {
    AdManager.instance.initialize(adConfig);
  }

  /// Sets the splash ad callback.
  /// This should be set before calling initialize if you want a callback
  /// when splash ad loads or fails.
  void setSplashAdCallback(Function(AppOpenAd? ad, AdError? error) callback) {
    _adManager.setSplashAdCallback(callback);
  }

  /// Displays a native ad.
  /// Pass [isSmall] as true for small ad, false for medium. Defaults to medium.
  showNativeAd({bool? isSmall}) {
    return _adManager.showNativeAd(isSmall: isSmall);
  }

  /// Displays the open app ad (not the splash ad).
  showOpenApp() {
    return _adManager.showOpenApp();
  }

  /// Displays a banner ad if available.
  showBannerAd() {
    return _adManager.showBannerAd();
  }

  /// Shows the ad counter, typically for debugging or development.
  /// Defaults to showing the counter.
  showAdCounter({bool? showCounter}) {
    return _adManager.showAdCounter(showCounter: showCounter);
  }

  /// Displays an interstitial ad.
  /// Returns the [InterstitialAd] or [AdError] through the [callBack].
  showAdInterstitialAd({
    required Function(InterstitialAd? ad, AdError? error) callBack,
  }) {
    return _adManager.showAdInterstitialAd(callBack: callBack);
  }

  /// Displays a rewarded ad.
  /// Returns the [RewardedAd] or [AdError] via [callBack],
  /// and handles the reward logic via [onReward].
  showAdRewardedAd({
    required void Function(RewardedAd? ad, AdError? error) callBack,
    required void Function(AdWithoutView ad, RewardItem reward) onReward,
  }) {
    return _adManager.showAdRewardedAd(callBack: callBack, onReward: onReward);
  }
}

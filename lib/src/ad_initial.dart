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

  /// Displays a preloaded native ad in the UI.
  ///
  /// Specify [nativeADType] as [NativeADType.small] or [NativeADType.medium].
  /// Returns a [Widget] that contains the ad, or an empty [SizedBox] if no ad is available.
  Widget showNativeAd({NativeADType nativeADType = NativeADType.medium}) {
    return _adManager.showNativeAd(nativeADType: nativeADType);
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
}

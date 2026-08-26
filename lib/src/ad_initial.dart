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

  /// Initializes the ad system with optional [adConfigData].
  /// Loads and prepares ads if configuration allows.
  Future<void> initialize({AdConfigData? adConfigData}) async {
    await AdManager.instance.initialize(adConfigData);
  }

  /// Sets the ad theme mode dynamically (system, light, dark).
  Future<void> setThemeMode(AdThemeMode mode, {BuildContext? context}) async {
    await _adManager.setThemeMode(mode, context: context);
  }

  /// Static shortcut to initialize the ad system with optional [adConfigData].
  static Future<void> init({AdConfigData? adConfigData}) async {
    await instance.initialize(adConfigData: adConfigData);
  }

  /// Reloads native ads (Medium and Small).
  void reloadNativeAd({NativeADType? nativeADType}) {
    _adManager.reloadNativeAd(nativeADType: nativeADType);
  }

  /// Triggers background reloading of any ad format that was lost or failed to load (e.g. after network returns).
  void reloadUnloadedAds() {
    _adManager.reloadUnloadedAds();
  }

  /// Static shortcut to trigger background reloading of all missing/unloaded ads.
  static void reloadAllUnloadedAds() {
    instance.reloadUnloadedAds();
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

  /// Displays a banner ad if available. Pass [isCollapsible] ('bottom' or 'top') for collapsible banner ads.
  Widget showBannerAd({String? isCollapsible}) {
    return _adManager.showBannerAd(isCollapsible: isCollapsible);
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

  /// Displays a rewarded interstitial ad.
  ///
  /// Provide a [callBack] to receive the [RewardedInterstitialAd] or [AdError] when the ad is shown or fails.
  /// The [onReward] function is called when the user successfully earns the reward.
  void showRewardedInterstitialAd({
    required void Function(RewardedInterstitialAd? ad, AdError? error) callBack,
    required void Function(AdWithoutView ad, RewardItem reward) onReward,
  }) {
    return _adManager.showRewardedInterstitialAd(
      callBack: callBack,
      onReward: onReward,
    );
  }
}

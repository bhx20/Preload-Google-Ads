import '../../preload_google_ads.dart';

class AdRepoImpl extends AdRepo {
  /// Loads the App Open ad using the LifeCycleManager
  @override
  Future<void> loadAppOpenAd() {
    return LifeCycleManager.instance.getOpenAppAdvertise();
  }

  /// Loads the Interstitial ad using the InterAd instance
  @override
  void loadInterAd() {
    return InterAd.instance.load();
  }

  /// Loads the medium-sized native ad using LoadMediumNative instance
  @override
  Future<void> loadMediumNative() {
    return LoadMediumNative.instance.loadAd();
  }

  /// Loads the small-sized native ad using LoadSmallNative instance
  @override
  Future<void> loadSmallNative() {
    return LoadSmallNative.instance.loadAd();
  }

  /// Displays the ad counter widget. The [showCounter] value determines if the counter should be shown.
  @override
  Widget showAdCounter(bool showCounter) {
    return AdCounterWidget(showCounter: ValueNotifier(showCounter));
  }

  /// Displays the banner ad using ShowBannerAd instance
  @override
  Widget showBannerAd() {
    return ShowBannerAd();
  }

  /// Displays the Interstitial ad by calling the showInter method of InterAd
  @override
  void showInterAd({
    required Function({InterstitialAd? ad, AdError? error}) callBack,
  }) {
    return InterAd.instance.showInter(callBack: callBack);
  }

  /// Displays the native ad, where [isSmall] determines if it is small or large.
  @override
  Widget showNative({bool isSmall = false}) {
    return ShowNative(isSmall: isSmall);
  }

  /// Displays the app open ad on splash screen using GoogleAppOpenOnSplash instance
  @override
  showOpenAppOnSplash({
    required Function({AppOpenAd? ad, AdError? error}) callBack,
  }) {
    return GoogleAppOpenOnSplash.instance.loadAndShowSplashAd(
      callBack: callBack,
    );
  }

  /// Displays the app open ad using AppOpenAdManager instance if available
  @override
  void showOpenAppAd() {
    return AppOpenAdManager.instance.showAdIfAvailable();
  }

  /// Loads the banner ad using LoadBannerAd instance
  @override
  Future<void> loadBannerAd() {
    return LoadBannerAd.instance.loadAd();
  }

  /// Loads the rewarded ad using RewardAd instance
  @override
  void loadRewardedAd() {
    return RewardAd.instance.load();
  }

  /// Displays the rewarded ad using RewardAd instance
  @override
  void showRewardedAd({
    required Function({RewardedAd? ad, AdError? error}) callBack,
    required Function(AdWithoutView ad, RewardItem reward) onReward,
  }) {
    return RewardAd.instance.showRewarded(
      callBack: callBack,
      onReward: onReward,
    );
  }
}

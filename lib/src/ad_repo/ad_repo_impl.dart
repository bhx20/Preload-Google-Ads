import '../ad_internal.dart';

/// Concrete implementation of [AdRepo] that connects the UI to the underlying ad managers and loaders.
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


  /// Displays the ad counter widget. The [showCounter] value determines if the counter should be shown.
  @override
  Widget showAdCounter(bool showCounter) {
    return AdCounterWidget(showCounter: ValueNotifier(showCounter));
  }

  /// Displays the banner ad using ShowBannerAd instance
  @override
  Widget showBannerAd() {
    if (!shouldShowBannerAd) return const SizedBox.shrink();
    return const ShowBannerAd();
  }

  /// Displays the Interstitial ad by calling the showInter method of InterAd
  @override
  void showInterAd({
    required Function({InterstitialAd? ad, AdError? error}) callBack,
  }) {
    return InterAd.instance.showInter(callBack: callBack);
  }



  /// Displays the app open ad on splash screen using GoogleAppOpenOnSplash instance
  @override
  Future<void> showOpenAppOnSplash({
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
    if (!shouldShowBannerAd) return Future.value();
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

  /// Resets all ad state and disposes of loaded ads.
  @override
  void resetAll() {
    LoadBannerAd.instance.reset();
    InterAd.instance.reset();
    RewardAd.instance.reset();
    DynamicNativeLoaderManager.instance.resetAll();
    // App Open ads are usually managed by lifecycle, but we can reset their managers if needed.
    // Assuming lifecycle managers handle their own state or don't need explicit reset here.
  }
}

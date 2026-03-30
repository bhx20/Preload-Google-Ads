import '../ad_internal.dart';

/// Singleton pattern to get the instance of AdRepoImpl
class PlugAd {
  static final AdRepoImpl _instance = AdRepoImpl();

  /// Returns an instance of AdRepoImpl, the concrete implementation of AdRepo
  static AdRepoImpl getInstance() {
    return _instance;
  }
}

/// Abstract class defining the required methods for the Ad repository
abstract class AdRepo {


  /// Loads the banner ad.
  Future<void> loadBannerAd();

  /// Displays the banner ad.
  Widget showBannerAd();

  /// Loads the app open ad.
  Future<void> loadAppOpenAd();

  /// Displays the app open ad.
  void showOpenAppAd();

  /// Displays the splash ad when the app is opened.
  /// A callback function is passed to handle success or failure of loading the ad.
  void showOpenAppOnSplash({
    required void Function({AppOpenAd? ad, AdError? error}) callBack,
  });

  /// Loads the interstitial ad.
  void loadInterAd();

  /// Displays the interstitial ad.
  /// A callback function is passed to handle success or failure of the ad.
  void showInterAd({
    required Function({InterstitialAd? ad, AdError? error}) callBack,
  });

  /// Loads the rewarded ad.
  void loadRewardedAd();

  /// Displays the rewarded ad.
  /// Callback functions are passed to handle the ad state (success or failure) and reward information.
  void showRewardedAd({
    required Function({RewardedAd? ad, AdError? error}) callBack,
    required Function(AdWithoutView ad, RewardItem reward) onReward,
  });

  /// Displays the ad counter.
  /// The [showCounter] boolean determines if the ad counter should be shown.
  Widget showAdCounter(bool showCounter);

  /// Resets all ad state and disposes of loaded ads.
  void resetAll();
}

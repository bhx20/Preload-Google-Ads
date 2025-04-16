import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../preload_ad.dart';

class PreloadGoogleAds {
  /// Private constructor for singleton
  PreloadGoogleAds._privateConstructor();

  /// Singleton instance
  static final PreloadGoogleAds instance =
      PreloadGoogleAds._privateConstructor();

  /// Holds the configuration data loaded during initialization
  late PreloadDataModel initialData;

  /// Callback to be executed after splash ad finishes loading/showing
  Function(AppOpenAd? ad, AdError? error)? _splashAdCallback;

  /// Initializes the ad system and loads ads based on the provided config
  void initialize({PreloadDataModel? adConfig}) {
    MobileAds.instance.initialize();
    initialData = setConfigData(adConfig);

    if (initialData.showAd == true) {
      _loadAndShowSplashAd();
      _loadNativeAd();
      _loadBannerAd();
      _loadOpenAppAd();
      _loadInterAd();
      _loadRewardedAd();
    }
  }

  /// Loads and shows the splash screen ad if enabled in config
  void _loadAndShowSplashAd() {
    if (initialData.showSplashAd) {
      PlugAd.getInstance().showOpenAppOnSplash(
        callBack: ({AppOpenAd? ad, AdError? error}) {
          _splashAdCallback?.call(ad, error);
          _splashAdCallback = null; // Clear after use
        },
      );
    } else {
      _splashAdCallback?.call(null, null);
      _splashAdCallback = null;
    }
  }

  /// Loads both small and medium native ads
  _loadNativeAd() {
    if (initialData.showNative == true && initialData.showAd == true) {
      PlugAd.getInstance().loadMediumNative();
      PlugAd.getInstance().loadSmallNative();
    }
  }

  /// Loads banner ad
  _loadBannerAd() {
    if (initialData.showBanner == true && initialData.showAd == true) {
      PlugAd.getInstance().loadBannerAd();
    }
  }

  /// Loads open app ad (used for background/resume events)
  _loadOpenAppAd() {
    if (initialData.showOpenApp == true && initialData.showAd == true) {
      PlugAd.getInstance().loadAppOpenAd();
    }
  }

  /// Loads interstitial ad
  _loadInterAd() {
    if (initialData.showInterstitial == true && initialData.showAd == true) {
      PlugAd.getInstance().loadInterAd();
    }
  }

  /// Loads rewarded ad
  _loadRewardedAd() {
    if (initialData.showRewarded == true && initialData.showAd == true) {
      PlugAd.getInstance().loadRewardedAd();
    }
  }

  /// Sets the callback for splash ad. Should be set before loading splash.
  void setSplashAdCallback(Function(AppOpenAd? ad, AdError? error) callback) {
    _splashAdCallback = callback;
  }

  /// Displays native ad (choose small or medium via isSmall)
  showNativeAd({bool? isSmall}) {
    return PlugAd.getInstance().showNative(isSmall: isSmall ?? false);
  }

  /// Displays open app ad (not splash)
  showOpenApp() {
    return PlugAd.getInstance().showOpenAppAd();
  }

  /// Displays banner ad
  showBannerAd() {
    return PlugAd.getInstance().showBannerAd();
  }

  /// Shows debug ad counter (for dev/testing stats)
  showAdCounter({bool? showCounter}) {
    return PlugAd.getInstance().showAdCounter(showCounter ?? true);
  }

  /// Shows interstitial ad and returns ad or error via callback
  showAdInterstitialAd({
    required Function(InterstitialAd? ad, AdError? error) callBack,
  }) {
    return PlugAd.getInstance().showInterAd(
      callBack: ({InterstitialAd? ad, AdError? error}) {
        callBack(ad, error);
      },
    );
  }

  /// Shows rewarded ad, returns ad or error, and handles reward grant
  showAdRewardedAd({
    required void Function(RewardedAd? ad, AdError? error) callBack,
    required void Function(AdWithoutView ad, RewardItem reward) onReward,
  }) {
    return PlugAd.getInstance().showRewardedAd(
      callBack: ({RewardedAd? ad, AdError? error}) {
        callBack(ad, error);
      },
      onReward: (AdWithoutView ad, RewardItem reward) {
        onReward(ad, reward);
      },
    );
  }
}

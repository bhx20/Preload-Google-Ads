import '../../preload_google_ads.dart';

/// Singleton class responsible for managing all ad operations.
class AdManager {
  /// Singleton instance of AdManager
  static final AdManager _instance = AdManager._internal();

  /// Factory constructor to provide access to the single instance of AdManager
  factory AdManager() => _instance;

  /// Private named constructor to ensure only one instance is created
  AdManager._internal();

  /// Getter for the singleton instance of AdManager
  static AdManager get instance => _instance;

  /// The current ad configuration
  late AdConfigData config;

  /// Callback for splash ad
  Function(AppOpenAd? ad, AdError? error)? _splashAdCallback;

  /// Initializes the AdManager with the provided ad configuration.
  /// It also initializes mobile ads and loads the required ads based on the configuration.
  Future<void> initialize(AdConfigData? adConfig) async {
    // Set the ad configuration data
    config = await setConfigData(adConfig);

    // Initialize the Google Mobile Ads SDK
    await MobileAds.instance.initialize();

    // Load and show ads if required
    if (shouldShowAd) {
      _loadAndShowSplashAd();
      _loadNativeAd();
      _loadBannerAd();
      _loadOpenAppAd();
      _loadInterAd();
      _loadRewardedAd();
    }
  }

  /// Loads and shows the splash ad if enabled in the ad configuration.
  /// Calls the provided callback when the ad is ready or fails to load.
  void _loadAndShowSplashAd() {
    if (shouldShowSplashAd) {
      // Show the splash ad if enabled
      PlugAd.getInstance().showOpenAppOnSplash(
        callBack: ({AppOpenAd? ad, AdError? error}) {
          /// Invoke the splash ad callback with the ad or error
          _splashAdCallback?.call(ad, error);

          /// Reset the callback after it has been called
          _splashAdCallback = null;
        },
      );
    } else {
      /// If splash ad isn't enabled, reset the callback
      _splashAdCallback?.call(null, null);
      _splashAdCallback = null;
    }
  }

  /// Loads native ads (both small and medium) if enabled in the ad configuration.
  void _loadNativeAd() {
    if (shouldShowNativeAd) {
      PlugAd.getInstance().loadMediumNative();
      PlugAd.getInstance().loadSmallNative();
    }
  }

  /// Loads a banner ad if enabled in the ad configuration.
  void _loadBannerAd() {
    if (shouldShowBannerAd) {
      PlugAd.getInstance().loadBannerAd();
    }
  }

  /// Loads the open app ad if enabled in the ad configuration.
  void _loadOpenAppAd() {
    if (shouldShowOpenAppAd) {
      PlugAd.getInstance().loadAppOpenAd();
    }
  }

  /// Loads the interstitial ad if enabled in the ad configuration.
  void _loadInterAd() {
    if (shouldShowInterAd) {
      PlugAd.getInstance().loadInterAd();
    }
  }

  /// Loads the rewarded ad if enabled in the ad configuration.
  void _loadRewardedAd() {
    if (shouldShowRewardedAd) {
      PlugAd.getInstance().loadRewardedAd();
    }
  }

  /// Sets the callback function to be invoked when the splash ad is ready or fails.
  void setSplashAdCallback(Function(AppOpenAd? ad, AdError? error) callback) {
    _splashAdCallback = callback;
  }

  /// Below methods are used to show various types of ads

  /// Shows a native ad. Optionally specify if it is a small or medium-sized ad.
  showNativeAd({NativeADType nativeADType = NativeADType.medium}) {
    return PlugAd.getInstance().showNative(nativeADType: nativeADType);
  }

  /// Shows the open app ad.
  showOpenApp() {
    return PlugAd.getInstance().showOpenAppAd();
  }

  /// Shows the banner ad.
  showBannerAd() {
    return PlugAd.getInstance().showBannerAd();
  }

  /// Displays the ad counter (if available).
  showAdCounter({bool? showCounter}) {
    return PlugAd.getInstance().showAdCounter(showCounter ?? true);
  }

  /// Shows the interstitial ad and invokes the provided callback with the ad or error.
  showInterstitialAd({
    required Function(InterstitialAd? ad, AdError? error) callBack,
  }) {
    return PlugAd.getInstance().showInterAd(
      callBack: ({InterstitialAd? ad, AdError? error}) {
        callBack(ad, error);
      },
    );
  }

  /// Shows the rewarded ad and invokes the provided callbacks with the ad, error, and reward information.
  showRewardedAd({
    required void Function(RewardedAd? ad, AdError? error) callBack,
    required void Function(AdWithoutView ad, RewardItem reward) onReward,
  }) {
    return PlugAd.getInstance().showRewardedAd(
      callBack: ({RewardedAd? ad, AdError? error}) {
        callBack(ad, error);
      },
      onReward: onReward,
    );
  }
}

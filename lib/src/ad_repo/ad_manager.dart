import '../ad_internal.dart';

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
  AdConfigData config = preData;

  /// Callback for splash ad
  Function(AppOpenAd? ad, AdError? error)? _splashAdCallback;

  /// Initializes the AdManager with the provided ad configuration.
  /// It also initializes mobile ads and loads the required ads based on the configuration.
  Future<void> initialize(AdConfigData? adConfig) async {
    // Reset any existing ad state before initializing with new config
    PlugAd.getInstance().resetAll();

    // Set the ad configuration data
    config = await setConfigData(adConfig);

    // Sync initial native channel ad style based on configured mode
    await _syncNativeAdStyle();

    // Initialize the Google Mobile Ads SDK
    await MobileAds.instance.initialize();

    // Load and show ads if required with staggered delays to prevent WebView creation issues
    if (shouldShowAd) {
      _loadAndShowSplashAd();
      Future.delayed(const Duration(milliseconds: 200), _loadNativeAd);
      Future.delayed(const Duration(milliseconds: 400), _loadBannerAd);
      Future.delayed(const Duration(milliseconds: 600), _loadOpenAppAd);
      Future.delayed(const Duration(milliseconds: 800), _loadInterAd);
      Future.delayed(const Duration(milliseconds: 1000), _loadRewardedAd);
      Future.delayed(const Duration(milliseconds: 1200), _loadRewardedInterAd);
    }
  }

  /// Sets the ad theme mode dynamically at runtime and updates native styles.
  Future<void> setThemeMode(AdThemeMode mode, {BuildContext? context}) async {
    config = AdConfigData(
      adIDs: config.adIDs,
      adCounter: config.adCounter,
      adFlag: config.adFlag,
      nativeADLayout: config.nativeADLayout,
      bannerADLayout: config.bannerADLayout,
      themeMode: mode,
    );
    await _syncNativeAdStyle(context: context);
  }

  /// Syncs native Kotlin/Swift ad styling via MethodChannel.
  Future<void> _syncNativeAdStyle({BuildContext? context}) async {
    final style = NativeADStyle.instance.getCustomStyle(context: context);
    await setAdStyleData(style);
  }

  /// Force reloads native ads (Small or Medium).
  void reloadNativeAd({NativeADType? nativeADType}) {
    if (nativeADType == NativeADType.small) {
      LoadSmallNative.instance.loadAd();
    } else if (nativeADType == NativeADType.medium) {
      LoadMediumNative.instance.loadAd();
    } else {
      LoadMediumNative.instance.loadAd();
      LoadSmallNative.instance.loadAd();
    }
  }

  /// Triggers background reloading of any ad format that failed or was lost due to network issues.
  void reloadUnloadedAds() {
    if (!shouldShowAd) return;

    if (shouldShowRewardedAd && !RewardAd.instance.isAdLoaded) {
      RewardAd.instance.load();
    }
    if (shouldShowRewardedInterAd && !RewardInterAd.instance.isAdLoaded) {
      RewardInterAd.instance.load();
    }
    if (shouldShowInterAd && !InterAd.instance.isAdLoaded) {
      InterAd.instance.load();
    }
    if (shouldShowBannerAd && LoadBannerAd.instance.bannerAdObject.isEmpty) {
      LoadBannerAd.instance.loadAd();
    }
    if (shouldShowNativeAd) {
      if (LoadMediumNative.instance.ads.isEmpty) {
        LoadMediumNative.instance.loadAd();
      }
      if (LoadSmallNative.instance.ads.isEmpty) {
        LoadSmallNative.instance.loadAd();
      }
    }
    if (shouldShowOpenAppAd && !AppOpenAdManager.instance.isAdAvailable) {
      AppOpenAdManager.instance.loadAd();
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

  /// Loads the rewarded interstitial ad if enabled in the ad configuration.
  void _loadRewardedInterAd() {
    if (shouldShowRewardedInterAd) {
      PlugAd.getInstance().loadRewardedInterAd();
    }
  }

  /// Sets the callback function to be invoked when the splash ad is ready or fails.
  void setSplashAdCallback(Function(AppOpenAd? ad, AdError? error) callback) {
    _splashAdCallback = callback;
  }

  /// Below methods are used to show various types of ads

  /// Shows a native ad. Optionally specify if it is a small or medium-sized ad.
  Widget showNativeAd({NativeADType nativeADType = NativeADType.medium}) {
    return PlugAd.getInstance().showNative(nativeADType: nativeADType);
  }

  /// Shows the open app ad.
  void showOpenApp() {
    return PlugAd.getInstance().showOpenAppAd();
  }

  /// Shows the banner ad (standard or collapsible).
  Widget showBannerAd({String? isCollapsible}) {
    return PlugAd.getInstance().showBannerAd(isCollapsible: isCollapsible);
  }

  /// Displays the ad counter (if available).
  Widget showAdCounter({bool? showCounter}) {
    return PlugAd.getInstance().showAdCounter(showCounter ?? true);
  }

  /// Shows the interstitial ad and invokes the provided callback with the ad or error.
  void showInterstitialAd({
    required Function(InterstitialAd? ad, AdError? error) callBack,
  }) {
    return PlugAd.getInstance().showInterAd(
      callBack: ({InterstitialAd? ad, AdError? error}) {
        callBack(ad, error);
      },
    );
  }

  /// Shows the rewarded ad and invokes the provided callbacks with the ad, error, and reward information.
  void showRewardedAd({
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

  /// Shows the rewarded interstitial ad and invokes the provided callbacks with the ad, error, and reward information.
  void showRewardedInterstitialAd({
    required void Function(RewardedInterstitialAd? ad, AdError? error) callBack,
    required void Function(AdWithoutView ad, RewardItem reward) onReward,
  }) {
    return PlugAd.getInstance().showRewardedInterAd(
      callBack: ({RewardedInterstitialAd? ad, AdError? error}) {
        callBack(ad, error);
      },
      onReward: onReward,
    );
  }
}

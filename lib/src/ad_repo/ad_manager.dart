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

  /// Initializes the AdManager with the provided ad configuration.
  /// It also initializes mobile ads and loads the required ads based on the configuration.
  Future<void> initialize(AdConfigData? adConfig) async {
    // Set the ad configuration data
    config = await setConfigData(adConfig);

    // Sync initial native channel ad style based on configured mode
    await _syncNativeAdStyle();

    // Initialize the Google Mobile Ads SDK
    await MobileAds.instance.initialize();

    // High Match-Rate & Non-Intrusive UX Strategy:
    // Mobile Ads SDK initialized cleanly without forcing any splash ad on app startup.
    // Ads are loaded purely on-demand when requested by the application.
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
  Future<void> reloadNativeAd({NativeADType? nativeADType, BuildContext? context}) async {
    await _syncNativeAdStyle(context: context);
    if (nativeADType == NativeADType.small) {
      LoadSmallNative.instance.reset();
      LoadSmallNative.instance.loadAd();
    } else if (nativeADType == NativeADType.medium) {
      LoadMediumNative.instance.reset();
      LoadMediumNative.instance.loadAd();
    } else {
      LoadMediumNative.instance.reset();
      LoadSmallNative.instance.reset();
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



  /// Below methods are used to show various types of ads

  /// Shows a native ad. Optionally specify if it is a small or medium-sized ad.
  Widget showNativeAd({NativeADType nativeADType = NativeADType.medium}) {
    return PlugAd.getInstance().showNative(nativeADType: nativeADType);
  }

  /// Shows the open app ad.
  void showOpenApp() {
    return PlugAd.getInstance().showOpenAppAd();
  }

  /// Shows a standard anchored banner ad.
  Widget showBannerAd() {
    return PlugAd.getInstance().showBannerAd();
  }

  /// Shows a collapsible banner ad ([CollapsibleBannerPosition.bottom] or [CollapsibleBannerPosition.top]).
  Widget showCollapsibleBannerAd({CollapsibleBannerPosition collapsiblePosition = CollapsibleBannerPosition.bottom}) {
    return PlugAd.getInstance().showCollapsibleBannerAd(collapsiblePosition: collapsiblePosition);
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

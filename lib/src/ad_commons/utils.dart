import '../ad_internal.dart';

///==============================================================================
///              **  Initial Config Data Function  **
///==============================================================================

/// Initial ad configuration with default values and test IDs.
AdConfigData preData = AdConfigData(
  adIDs: AdIDS(
    appOpenId: AdTestIds.appOpen,
    bannerId: AdTestIds.banner,
    nativeId: AdTestIds.native,
    interstitialId: AdTestIds.interstitial,
    rewardedId: AdTestIds.rewarded,
    customFactories: [],
  ),
  adCounter: AdCounter(
    interstitialCounter: 0,
    rewardedCounter: 0,
  ),
  adFlag: AdFlag(
    showAd: true,
    showBanner: true,
    showInterstitial: true,
    showOpenApp: true,
    showRewarded: true,
    showSplashAd: false,
  ),
);

///==============================================================================
///              **  Set Config Data Function  **
///==============================================================================

/// Sets the configuration data for ads, allowing custom values for each ad type.
/// Uses default values from [preData] if no configuration is provided.
Future<AdConfigData> setConfigData(AdConfigData? adConfig) async {
  if (adConfig?.adIDs?.customFactories != null) {
    await setCustomFactoryLayouts(adConfig!.adIDs!.customFactories!);
  }
  return AdConfigData(
    adIDs: AdIDS(
      appOpenId: adConfig?.adIDs?.appOpenId ?? preData.adIDs?.appOpenId,
      bannerId: adConfig?.adIDs?.bannerId ?? preData.adIDs?.bannerId,
      nativeId: adConfig?.adIDs?.nativeId ?? preData.adIDs?.nativeId,
      interstitialId:
          adConfig?.adIDs?.interstitialId ?? preData.adIDs?.interstitialId,
      rewardedId: adConfig?.adIDs?.rewardedId ?? preData.adIDs?.rewardedId,
      customFactories:
          adConfig?.adIDs?.customFactories ?? preData.adIDs?.customFactories,
    ),
    adCounter: AdCounter(
      interstitialCounter: adConfig?.adCounter?.interstitialCounter ??
          preData.adCounter?.interstitialCounter,
      rewardedCounter: adConfig?.adCounter?.rewardedCounter ??
          preData.adCounter?.rewardedCounter,
    ),
    adFlag: AdFlag(
      showAd: adConfig?.adFlag?.showAd ?? preData.adFlag?.showAd,
      showBanner: adConfig?.adFlag?.showBanner ?? preData.adFlag?.showBanner,
      showInterstitial: adConfig?.adFlag?.showInterstitial ??
          preData.adFlag?.showInterstitial,
      showOpenApp: adConfig?.adFlag?.showOpenApp ?? preData.adFlag?.showOpenApp,
      showRewarded:
          adConfig?.adFlag?.showRewarded ?? preData.adFlag?.showRewarded,
      showSplashAd:
          adConfig?.adFlag?.showSplashAd ?? preData.adFlag?.showSplashAd,
    ),
  );
}

/// Sends custom native ad factory layouts to the native platform.
Future<void> setCustomFactoryLayouts(
    List<NativeAdFactoryConfig> factories) async {
  final channel = MethodChannel(nativeChannel);
  final layouts = factories.map((f) => f.toJson()).toList();
  await channel.invokeMethod('setCustomFactoryLayouts', {'factories': layouts});
}

///==============================================================================
///              **  Ad Stats Function  **
///==============================================================================

/// Singleton class for tracking the statistics of various ads.
class AdStats {
  /// Private constructor to prevent external instantiation
  AdStats._privateConstructor();

  /// Singleton instance for accessing [AdStats]
  static final AdStats _instance = AdStats._privateConstructor();

  /// Getter to access the singleton instance
  static AdStats get instance => _instance;

  /// Statistics for Interstitial Ads
  /// Number of interstitial ads loaded.
  final ValueNotifier<int> interLoad = ValueNotifier(0);

  /// Number of interstitial ad impressions.
  final ValueNotifier<int> interImp = ValueNotifier(0);

  /// Number of interstitial ad load failures.
  final ValueNotifier<int> interFailed = ValueNotifier(0);

  /// Statistics for Rewarded Ads
  /// Number of rewarded ads loaded.
  final ValueNotifier<int> rewardedLoad = ValueNotifier(0);

  /// Number of rewarded ad impressions.
  final ValueNotifier<int> rewardedImp = ValueNotifier(0);

  /// Number of rewarded ad load failures.
  final ValueNotifier<int> rewardedFailed = ValueNotifier(0);

  /// Statistics for App Open Ads
  /// Number of app open ads loaded.
  final ValueNotifier<int> openAppLoad = ValueNotifier(0);

  /// Number of app open ad impressions.
  final ValueNotifier<int> openAppImp = ValueNotifier(0);

  /// Number of app open ad load failures.
  final ValueNotifier<int> openAppFailed = ValueNotifier(0);

  /// Statistics for Banner Ads
  /// Number of banner ads loaded.
  final ValueNotifier<int> bannerLoad = ValueNotifier(0);

  /// Number of banner ad impressions.
  final ValueNotifier<int> bannerImp = ValueNotifier(0);

  /// Number of banner ad load failures.
  final ValueNotifier<int> bannerFailed = ValueNotifier(0);
}

///==============================================================================
///              **  Hex To Color Function  **
///==============================================================================

/// Converts a [Color] to its hexadecimal string representation.
///
/// [color] The [Color] object to convert.
String colorToHex(Color color) {
  /// Accessing the RGBA components using the new accessors
  final r = (color.r * 255).toInt();
  final g = (color.g * 255).toInt();
  final b = (color.b * 255).toInt();

  /// Convert to hex and pad with leading zeros
  final rHex = r.toRadixString(16).padLeft(2, '0');
  final gHex = g.toRadixString(16).padLeft(2, '0');
  final bHex = b.toRadixString(16).padLeft(2, '0');

  /// Combine components into hex string
  return '#${rHex + gHex + bHex}'.toUpperCase();
}

///==============================================================================
///              **  Plug Unit ID's & AD Flags  **
///==============================================================================

/// Retrieves the current [AdConfigData] from the [AdManager].
AdConfigData get config => AdManager.instance.config;

/// Retrieves the App Open Ad Unit ID.
String get unitIDAppOpen => config.adIDs?.appOpenId ?? AdTestIds.appOpen;

/// Retrieves the Banner Ad Unit ID.
String get unitIDBanner => config.adIDs?.bannerId ?? AdTestIds.banner;

/// Retrieves the Interstitial Ad Unit ID.
String get unitIDInter =>
    config.adIDs?.interstitialId ?? AdTestIds.interstitial;

/// Retrieves the Native Ad Unit ID.
String get unitIDNative => config.adIDs?.nativeId ?? AdTestIds.native;

/// Retrieves the Rewarded Ad Unit ID.
String get unitIDRewarded => config.adIDs?.rewardedId ?? AdTestIds.rewarded;

/// Determines if any ads should be shown based on flags.
bool get shouldShowAd => config.adFlag?.showAd == true;

/// Determines if the splash ad should be shown.
bool get shouldShowSplashAd =>
    config.adFlag?.showSplashAd == true && config.adFlag?.showAd == true;

/// Determines if native ads should be shown.
bool get shouldShowNativeAd => config.adFlag?.showAd == true;

/// Determines if banner ads should be shown.
bool get shouldShowBannerAd =>
    config.adFlag?.showBanner == true && config.adFlag?.showAd == true;

/// Determines if interstitial ads should be shown.
bool get shouldShowInterAd =>
    config.adFlag?.showInterstitial == true && config.adFlag?.showAd == true;

/// Determines if rewarded ads should be shown.
bool get shouldShowRewardedAd =>
    config.adFlag?.showRewarded == true && config.adFlag?.showAd == true;

/// Determines if the Open App ad should be shown.
bool get shouldShowOpenAppAd =>
    config.adFlag?.showOpenApp == true && config.adFlag?.showAd == true;

/// Gets the interstitial ad counter.
int get getInterCounter => config.adCounter?.interstitialCounter ?? 0;

/// Gets the native ad counter.
int get getNativeCounter => 0; // Default to 0 (always show) for custom native ads

/// Gets the rewarded ad counter.
int get getRewardedCounter => config.adCounter?.rewardedCounter ?? 0;

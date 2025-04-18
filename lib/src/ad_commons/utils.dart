import '../../preload_google_ads.dart';

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
  ),
  adCounter: AdCounter(
    interstitialCounter: 0,
    nativeCounter: 0,
    rewardedCounter: 0,
  ),
  adFlag: AdFlag(
    showAd: true,
    showBanner: true,
    showInterstitial: true,
    showNative: true,
    showOpenApp: true,
    showRewarded: true,
    showSplashAd: false,
  ),
  nativeADLayout: NativeADLayout(
    padding: EdgeInsets.all(5),
    margin: EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
      borderRadius: BorderRadius.circular(5),
    ),
    adLayout: AdLayout.nativeLayout,
    customNativeADStyle: CustomNativeADStyle(),
    flutterNativeADStyle: FlutterNativeADStyle(),
  ),
);

///==============================================================================
///              **  Set Config Data Function  **
///==============================================================================

/// Sets the configuration data for ads, allowing custom values for each ad type.
/// Uses default values from [preData] if no configuration is provided.
setConfigData(AdConfigData? adConfig) async {
  await setAdStyleData(adConfig?.nativeADLayout?.customNativeADStyle);
  return AdConfigData(
    adIDs: AdIDS(
      appOpenId: adConfig?.adIDs?.appOpenId ?? preData.adIDs?.appOpenId,
      bannerId: adConfig?.adIDs?.bannerId ?? preData.adIDs?.bannerId,
      nativeId: adConfig?.adIDs?.nativeId ?? preData.adIDs?.nativeId,
      interstitialId:
          adConfig?.adIDs?.interstitialId ?? preData.adIDs?.interstitialId,
      rewardedId: adConfig?.adIDs?.rewardedId ?? preData.adIDs?.rewardedId,
    ),
    adCounter: AdCounter(
      interstitialCounter: adConfig?.adCounter?.interstitialCounter ??
          preData.adCounter?.interstitialCounter,
      nativeCounter: adConfig?.adCounter?.nativeCounter ??
          preData.adCounter?.nativeCounter,
      rewardedCounter: adConfig?.adCounter?.rewardedCounter ??
          preData.adCounter?.rewardedCounter,
    ),
    adFlag: AdFlag(
      showAd: adConfig?.adFlag?.showAd ?? preData.adFlag?.showAd,
      showBanner: adConfig?.adFlag?.showBanner ?? preData.adFlag?.showBanner,
      showInterstitial: adConfig?.adFlag?.showInterstitial ??
          preData.adFlag?.showInterstitial,
      showNative: adConfig?.adFlag?.showNative ?? preData.adFlag?.showNative,
      showOpenApp: adConfig?.adFlag?.showOpenApp ?? preData.adFlag?.showOpenApp,
      showRewarded:
          adConfig?.adFlag?.showRewarded ?? preData.adFlag?.showRewarded,
      showSplashAd:
          adConfig?.adFlag?.showSplashAd ?? preData.adFlag?.showSplashAd,
    ),
    nativeADLayout: NativeADLayout(
      decoration: adConfig?.nativeADLayout?.decoration ??
          preData.nativeADLayout?.decoration,
      margin:
          adConfig?.nativeADLayout?.padding ?? preData.nativeADLayout?.padding,
      padding:
          adConfig?.nativeADLayout?.margin ?? preData.nativeADLayout?.margin,
      adLayout: adConfig?.nativeADLayout?.adLayout ??
          preData.nativeADLayout?.adLayout,
      customNativeADStyle: adConfig?.nativeADLayout?.customNativeADStyle ??
          preData.nativeADLayout?.customNativeADStyle,
      flutterNativeADStyle: adConfig?.nativeADLayout?.flutterNativeADStyle ??
          preData.nativeADLayout?.flutterNativeADStyle,
    ),
  );
}

///==============================================================================
///              **  Set Ad Style Data Function  **
///==============================================================================

/// Sets the ad style data by invoking a method on the native platform.
/// This method adjusts the appearance of various ad components like buttons and text.
Future<void> setAdStyleData(CustomNativeADStyle? adStyle) async {
  final channel = MethodChannel(nativeChannel);

  /// Fallback to default ad style if none is provided
  adStyle ??= CustomNativeADStyle();

  /// Passes ad style data to the native platform.
  await channel.invokeMethod(nativeMethod, {
    "title": colorToHex(adStyle.titleColor),
    "description": colorToHex(adStyle.bodyColor),
    "tag_background": colorToHex(adStyle.tagBackground),
    "tag_foreground": colorToHex(adStyle.tagForeground),
    "button_background": colorToHex(adStyle.buttonBackground),
    "button_foreground": colorToHex(adStyle.buttonForeground),
    "button_radius": adStyle.buttonRadius,
    "tag_radius": adStyle.tagRadius,
    "button_gradients":
        adStyle.buttonGradients.map((color) => colorToHex(color)).toList(),
  });
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
  final ValueNotifier<int> interLoad = ValueNotifier(0);
  final ValueNotifier<int> interImp = ValueNotifier(0);
  final ValueNotifier<int> interFailed = ValueNotifier(0);

  /// Statistics for Rewarded Ads
  final ValueNotifier<int> rewardedLoad = ValueNotifier(0);
  final ValueNotifier<int> rewardedImp = ValueNotifier(0);
  final ValueNotifier<int> rewardedFailed = ValueNotifier(0);

  /// Statistics for Small Native Ads
  final ValueNotifier<int> nativeLoadS = ValueNotifier(0);
  final ValueNotifier<int> nativeImpS = ValueNotifier(0);
  final ValueNotifier<int> nativeFailedS = ValueNotifier(0);

  /// Statistics for Medium Native Ads
  final ValueNotifier<int> nativeLoadM = ValueNotifier(0);
  final ValueNotifier<int> nativeImpM = ValueNotifier(0);
  final ValueNotifier<int> nativeFailedM = ValueNotifier(0);

  /// Statistics for App Open Ads
  final ValueNotifier<int> openAppLoad = ValueNotifier(0);
  final ValueNotifier<int> openAppImp = ValueNotifier(0);
  final ValueNotifier<int> openAppFailed = ValueNotifier(0);

  /// Statistics for Banner Ads
  final ValueNotifier<int> bannerLoad = ValueNotifier(0);
  final ValueNotifier<int> bannerImp = ValueNotifier(0);
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
bool get shouldShowNativeAd =>
    config.adFlag?.showNative == true && config.adFlag?.showAd == true;

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
int get getNativeCounter => config.adCounter?.nativeCounter ?? 0;

/// Gets the rewarded ad counter.
int get getRewardedCounter => config.adCounter?.rewardedCounter ?? 0;

/// Gets the Layout Type
bool get isFlutterLayout =>
    config.nativeADLayout?.adLayout == AdLayout.flutterLayout;

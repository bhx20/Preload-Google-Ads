import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../preload_google_ads.dart';

//==============================================================================
//              **  AD Test ID Class  **
//==============================================================================

/// A utility class to manage Google AdMob Test Ad Unit IDs for both Android and iOS.
/// Easily extendable for production IDs later.
class AdTestIds {
  /// Banner Ad Unit ID
  static String get banner => _getId(
    androidId: 'ca-app-pub-3940256099942544/6300978111',
    iosId: 'ca-app-pub-3940256099942544/2934735716',
  );

  /// Interstitial Ad Unit ID
  static String get interstitial => _getId(
    androidId: 'ca-app-pub-3940256099942544/1033173712',
    iosId: 'ca-app-pub-3940256099942544/4411468910',
  );

  /// Rewarded Ad Unit ID
  static String get rewarded => _getId(
    androidId: 'ca-app-pub-3940256099942544/5224354917',
    iosId: 'ca-app-pub-3940256099942544/1712485313',
  );

  /// Rewarded Interstitial Ad Unit ID
  static String get rewardedInterstitial => _getId(
    androidId: 'ca-app-pub-3940256099942544/5354046379',
    iosId: 'ca-app-pub-3940256099942544/6978759866',
  );

  /// Native Advanced Ad Unit ID
  static String get native => _getId(
    androidId: 'ca-app-pub-3940256099942544/2247696110',
    iosId: 'ca-app-pub-3940256099942544/3986624511',
  );

  /// App Open Ad Unit ID
  static String get appOpen => _getId(
    androidId: 'ca-app-pub-3940256099942544/9257395921',
    iosId: 'ca-app-pub-3940256099942544/5662855259',
  );

  /// Helper method to select platform-specific Ad ID
  static String _getId({required String androidId, required String iosId}) {
    if (Platform.isAndroid) return androidId;
    if (Platform.isIOS) return iosId;
    throw UnsupportedError('Unsupported platform');
  }
}

//==============================================================================
//              **  Initial Config Data Function  **
//==============================================================================

AdConfigData preData = AdConfigData(
  appOpenId: AdTestIds.appOpen,
  bannerId: AdTestIds.banner,
  nativeId: AdTestIds.native,
  interstitialId: AdTestIds.interstitial,
  rewardedId: AdTestIds.rewarded,
  interstitialCounter: 0,
  nativeCounter: 0,
  rewardedCounter: 0,
  showAd: true,
  showBanner: true,
  showInterstitial: true,
  showNative: true,
  showOpenApp: true,
  showRewarded: true,
  showSplashAd: true,
);

//==============================================================================
//              **  Set Config Data Function  **
//==============================================================================

setConfigData(AdConfigData? adConfig) {
  return AdConfigData(
    appOpenId: adConfig?.appOpenId ?? preData.appOpenId,
    bannerId: adConfig?.bannerId ?? preData.bannerId,
    nativeId: adConfig?.nativeId ?? preData.nativeId,
    interstitialId: adConfig?.interstitialId ?? preData.interstitialId,
    rewardedId: adConfig?.rewardedId ?? preData.rewardedId,
    interstitialCounter:
        adConfig?.interstitialCounter ?? preData.interstitialCounter,
    nativeCounter: adConfig?.nativeCounter ?? preData.nativeCounter,
    showAd: adConfig?.showAd ?? preData.showAd,
    showBanner: adConfig?.showBanner ?? preData.showBanner,
    showInterstitial: adConfig?.showInterstitial ?? preData.showInterstitial,
    showNative: adConfig?.showNative ?? preData.showNative,
    showOpenApp: adConfig?.showOpenApp ?? preData.showOpenApp,
    showRewarded: adConfig?.showRewarded ?? preData.showRewarded,
    rewardedCounter: adConfig?.rewardedCounter ?? preData.rewardedCounter,
    showSplashAd: adConfig?.showSplashAd ?? preData.showSplashAd,
  );
}

//==============================================================================
//              **  Set Ad Style Data Function  **
//==============================================================================

Future<void> setAdStyleData(AdStyle? adStyle) async {
  final channel = MethodChannel('com.plug.preload/adButtonStyle');

  adStyle ??= AdStyle();

  await channel.invokeMethod('setAdStyle', {
    "title": colorToHex(adStyle.title),
    "description": colorToHex(adStyle.description),
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

//==============================================================================
//              **  Ad Stats Function  **
//==============================================================================

class AdStats {
  // Private constructor
  AdStats._privateConstructor();

  // Singleton instance
  static final AdStats _instance = AdStats._privateConstructor();

  // Getter to access the instance
  static AdStats get instance => _instance;

  // Interstitial
  final ValueNotifier<int> interLoad = ValueNotifier(0);
  final ValueNotifier<int> interImp = ValueNotifier(0);
  final ValueNotifier<int> interFailed = ValueNotifier(0);

  // Rewarded
  final ValueNotifier<int> rewardedLoad = ValueNotifier(0);
  final ValueNotifier<int> rewardedImp = ValueNotifier(0);
  final ValueNotifier<int> rewardedFailed = ValueNotifier(0);

  // Native Small
  final ValueNotifier<int> nativeLoadS = ValueNotifier(0);
  final ValueNotifier<int> nativeImpS = ValueNotifier(0);
  final ValueNotifier<int> nativeFailedS = ValueNotifier(0);

  // Native Medium
  final ValueNotifier<int> nativeLoadM = ValueNotifier(0);
  final ValueNotifier<int> nativeImpM = ValueNotifier(0);
  final ValueNotifier<int> nativeFailedM = ValueNotifier(0);

  // App Open
  final ValueNotifier<int> openAppLoad = ValueNotifier(0);
  final ValueNotifier<int> openAppImp = ValueNotifier(0);
  final ValueNotifier<int> openAppFailed = ValueNotifier(0);

  // Banner
  final ValueNotifier<int> bannerLoad = ValueNotifier(0);
  final ValueNotifier<int> bannerImp = ValueNotifier(0);
  final ValueNotifier<int> bannerFailed = ValueNotifier(0);
}

//==============================================================================
//              **  Hex To Color Function  **
//==============================================================================

String colorToHex(Color color) {
  /// Accessing the RGBA components using the new accessors
  final r = (color.r * 255).toInt();
  final g = (color.g * 255).toInt();
  final b = (color.b * 255).toInt();
  final a = (color.a * 255).toInt();

  /// Convert to hex and pad with leading zeros
  final rHex = r.toRadixString(16).padLeft(2, '0');
  final gHex = g.toRadixString(16).padLeft(2, '0');
  final bHex = b.toRadixString(16).padLeft(2, '0');
  final aHex = a.toRadixString(16).padLeft(2, '0');

  /// Combine components into hex string
  return '#${rHex + gHex + bHex}'.toUpperCase();
}

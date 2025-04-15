import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../preload_ad.dart';

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

PreloadDataModel preData = PreloadDataModel(
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

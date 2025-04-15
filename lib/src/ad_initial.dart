import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../preload_ad.dart';

class PreloadAds {
  PreloadAds._privateConstructor();

  static final PreloadAds instance = PreloadAds._privateConstructor();

  //==============================================================================
  //              **  Ads Properties  **
  //==============================================================================

  late PreloadDataModel initialData;

  //==============================================================================
  //              **  Ads initialize Function  **
  //==============================================================================

  void initialize({
    String? appOpenId,
    String? bannerId,
    String? rewardedId,
    String? rewardedInterstitialId,
    String? interstitialId,
    String? nativeId,
    int? nativeCounter,
    int? interstitialCounter,
    bool? showAd,
    bool? showBanner,
    bool? showInterstitial,
    bool? showNative,
    bool? showOpenApp,
    bool? showRewarded,
    bool? showSplashAd,
    bool? showRewardedInterstitial,
    Function()? onAdStartAdCallBack,
  }) {
    MobileAds.instance.initialize();
    initialData = PreloadDataModel(
      appOpenId: appOpenId ?? preData.appOpenId,
      bannerId: bannerId ?? preData.bannerId,
      nativeId: nativeId ?? preData.nativeId,
      interstitialId: interstitialId ?? preData.interstitialId,
      rewardedId: rewardedId ?? preData.rewardedId,
      rewardedInterstitialId:
          rewardedInterstitialId ?? preData.rewardedInterstitialId,
      interstitialCounter: interstitialCounter ?? preData.interstitialCounter,
      nativeCounter: nativeCounter ?? preData.nativeCounter,
      showAd: showAd ?? preData.showAd,
      showBanner: showBanner ?? preData.showBanner,
      showInterstitial: showInterstitial ?? preData.showInterstitial,
      showNative: showNative ?? preData.showNative,
      showOpenApp: showOpenApp ?? preData.showOpenApp,
      showRewarded: showRewarded ?? preData.showRewarded,
      showRewardedInterstitial:
          showRewardedInterstitial ?? preData.showRewardedInterstitial,
      showSplashAd: showSplashAd ?? preData.showSplashAd,
    );

    if (initialData.showAd == true) {
      _loadSplashAd(onAdStartAdCallBack);
      _loadNativeAd();
      _loadOpenAppAd();
      _loadInterAd();
    }
  }

  //==============================================================================
  //              ** Load Ads Functions  **
  //==============================================================================

  _loadSplashAd(Function()? onAdStartAdCallBack) {
    if (initialData.showSplashAd) {
      PlugAd.getInstance().showOpenAppOnSplash(
        onAdStartAdImpression: onAdStartAdCallBack ?? () {},
      );
    } else {
      onAdStartAdCallBack;
    }
  }

  _loadNativeAd() {
    if (initialData.showNative == true && initialData.showAd == true) {
      PlugAd.getInstance().loadMediumNative();
      PlugAd.getInstance().loadSmallNative();
    }
  }

  _loadOpenAppAd() {
    if (initialData.showOpenApp == true && initialData.showAd == true) {
      PlugAd.getInstance().loadAppOpenAd();
    }
  }

  _loadInterAd() {
    if (initialData.showInterstitial == true && initialData.showAd == true) {
      PlugAd.getInstance().loadInterAd();
    }
  }

  //==============================================================================
  //              ** Show Ads Functions  **
  //==============================================================================

  showNativeAd({bool? isSmall}) {
    return PlugAd.getInstance().showNative(isSmall: isSmall ?? false);
  }

  showBannerAd() {
    return PlugAd.getInstance().showBannerAd();
  }

  showAdCounter({bool? showCounter}) {
    return PlugAd.getInstance().showAdCounter(showCounter ?? true);
  }

  showAdInterstitialAd({Function()? callBack}) {
    return PlugAd.getInstance().showInterAd(() => callBack);
  }
}

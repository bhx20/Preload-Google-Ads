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
    PreloadDataModel? adConfig,
    Function()? onAdStartAdCallBack,
  }) {
    MobileAds.instance.initialize();
    initialData = PreloadDataModel(
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

    if (initialData.showAd == true) {
      _loadSplashAd(onAdStartAdCallBack);
      _loadNativeAd();
      _loadBannerAd();
      _loadOpenAppAd();
      _loadInterAd();
      _loadRewardedAd();
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

  _loadBannerAd() {
    if (initialData.showBanner == true && initialData.showAd == true) {
      PlugAd.getInstance().loadBannerAd();
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

  _loadRewardedAd() {
    if (initialData.showRewarded == true && initialData.showAd == true) {
      PlugAd.getInstance().loadRewardedAd();
    }
  }

  //==============================================================================
  //              ** Show Ads Functions  **
  //==============================================================================

  showNativeAd({bool? isSmall}) {
    return PlugAd.getInstance().showNative(isSmall: isSmall ?? false);
  }

  showOpenApp() {
    return PlugAd.getInstance().showOpenAppAd();
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

  showAdRewardedAd({
    required Function() callBack,
    required Function() onReward,
  }) {
    return PlugAd.getInstance().showRewardedAd(
      callBack: callBack,
      onReward: onReward,
    );
  }
}

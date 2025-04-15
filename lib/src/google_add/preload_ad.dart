import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../preload_google_ads.dart';

class PreloadAds {
  PreloadAds._privateConstructor();

  static final PreloadAds instance = PreloadAds._privateConstructor();

  late PreloadDataModel initialData;

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
    Function()? onAdStartAdImpression,
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
      if (initialData.showSplashAd) {
        GoogleAdd.getInstance().showOpenAppOnSplash(
          onAdStartAdImpression: onAdStartAdImpression ?? () {},
        );
      }
      // if (initialData.showNative == true && initialData.showAd == true) {
      //   GoogleAdd.getInstance().loadLargeNative();
      //   GoogleAdd.getInstance().loadSmallNative();
      // }

      GoogleAdd.getInstance().googleOpenAppAdd();
      GoogleAdd.getInstance().loadGoogleInterstitialAdd();
    }
  }

  showNativeAd({bool? isSmall}) {
    return GoogleAdd.getInstance().showNative(isSmall: isSmall ?? false);
  }

  showBannerAd() {
    return GoogleAdd.getInstance().googleBannerAdd();
  }

  showAdCounter({bool? showCounter}) {
    return GoogleAdd.getInstance().showAdCounter(showCounter ?? true);
  }

  showAdInterstitialAd({Function()? callBack}) {
    return GoogleAdd.getInstance().showGoogleInterstitialAdd(() => callBack);
  }
}

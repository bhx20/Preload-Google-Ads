class PreloadDataModel {
  final String appOpenId;
  final String bannerId;
  final String nativeId;
  final String interstitialId;
  final String rewardedId;
  final String rewardedInterstitialId;
  final int interstitialCounter;
  final int nativeCounter;
  final bool showAd;
  final bool showBanner;
  final bool showInterstitial;
  final bool showNative;
  final bool showSplashAd;
  final bool showOpenApp;
  final bool showRewarded;
  final bool showRewardedInterstitial;

  PreloadDataModel({
    required this.appOpenId,
    required this.bannerId,
    required this.interstitialId,
    required this.interstitialCounter,
    required this.nativeCounter,
    required this.nativeId,
    required this.showAd,
    required this.showBanner,
    required this.showInterstitial,
    required this.showNative,
    required this.showOpenApp,
    required this.rewardedId,
    required this.showSplashAd,
    required this.rewardedInterstitialId,
    required this.showRewarded,
    required this.showRewardedInterstitial,
  });
}

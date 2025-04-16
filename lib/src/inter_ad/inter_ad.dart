import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../preload_ad.dart';

class InterAd {
  static final InterAd instance = InterAd._internal();

  factory InterAd() {
    return instance;
  }

  InterAd._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  var counter = 0;

  void load() {
    try {
      _isInterstitialAdLoaded = false;
      InterstitialAd.load(
        adUnitId: PreloadGoogleAds.instance.initialData.interstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            AdStats.instance.interLoad.value++;
            AppLogger.log("inter loaded");
            _interstitialAd = ad;
            _interstitialAd!.setImmersiveMode(true);
            _isInterstitialAdLoaded = true;
          },
          onAdFailedToLoad: (LoadAdError error) {
            AdStats.instance.interFailed.value++;
            _interstitialAd = null;
            _isInterstitialAdLoaded = false;
          },
        ),
      );
    } catch (error) {
      _interstitialAd?.dispose();
    }
  }

  void showInter({
    required Function({InterstitialAd? ad, AdError? error}) callBack,
  }) {
    final data = PreloadGoogleAds.instance.initialData;

    if (data.showInterstitial == true && data.showAd == true) {
      /// Check if interstitial ad is ready and counter limit is reached
      if (_isInterstitialAdLoaded &&
          _interstitialAd != null &&
          counter >= data.interstitialCounter) {
        counter = 0;

        _interstitialAd!
          ..fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              callBack(ad: ad);
              ad.dispose();
              _interstitialAd = null;
              load();
            },
            onAdImpression: (_) {
              AdStats.instance.interImp.value++;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              callBack(ad: ad, error: error);
              AppLogger.error('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
              _interstitialAd = null;
              load();
            },
          )
          ..show();
      } else {
        counter++;
        callBack();
      }
    } else {
      callBack();
    }
  }
}

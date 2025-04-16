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

  void showAndNavigate({required Function() callBack}) {
    if (PreloadGoogleAds.instance.initialData.showInterstitial == true &&
        PreloadGoogleAds.instance.initialData.showAd == true) {
      if (_isInterstitialAdLoaded &&
          _interstitialAd != null &&
          counter >=
              PreloadGoogleAds.instance.initialData.interstitialCounter) {
        counter = 0;
        _interstitialAd!.show().then((value) {
          Future.delayed(const Duration(seconds: 2)).then((value) {
            callBack();
          });
          _interstitialAd!
              .fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              load();
            },
            onAdImpression: (value) {
              AdStats.instance.interImp.value++;
            },
            onAdFailedToShowFullScreenContent: (
              InterstitialAd ad,
              AdError error,
            ) async {
              AppLogger.error('$ad onAdFailedToShowFullScreenContent: $error');
              _interstitialAd = null;
              ad.dispose();
              load();
            },
          );
        });
      } else {
        counter++;
        callBack();
      }
    } else {
      callBack();
    }
  }
}

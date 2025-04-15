import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:preload_google_ads/preload_google_ads.dart';

class GoogleInterstitialAdvertise {
  static final GoogleInterstitialAdvertise instance =
      GoogleInterstitialAdvertise._internal();

  factory GoogleInterstitialAdvertise() {
    return instance;
  }

  GoogleInterstitialAdvertise._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  var counter = 0;

  void load() {
    try {
      _isInterstitialAdLoaded = false;
      InterstitialAd.load(
        adUnitId: PreloadAds.instance.initialData.interstitialId,
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
    if (PreloadAds.instance.initialData.showInterstitial == true &&
        PreloadAds.instance.initialData.showAd == true) {
      if (_isInterstitialAdLoaded &&
          _interstitialAd != null &&
          counter >= PreloadAds.instance.initialData.interstitialCounter) {
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

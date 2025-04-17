import '../../preload_google_ads.dart';

/// A singleton class to manage interstitial ads.
class InterAd {
  static final InterAd instance = InterAd._internal();

  factory InterAd() {
    return instance;
  }

  InterAd._internal();

  /// The interstitial ad object.
  InterstitialAd? _interstitialAd;

  /// A flag to check if the interstitial ad is loaded.
  bool _isInterstitialAdLoaded = false;

  /// A counter to track when the ad should be shown based on the limit.
  var counter = 0;

  /// Loads an interstitial ad.
  ///
  /// Attempts to load an interstitial ad and set its immersive mode when it's loaded.
  void load() {
    try {
      _isInterstitialAdLoaded = false;
      InterstitialAd.load(
        adUnitId: unitIDInter,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          /// Called when the ad is loaded successfully.
          onAdLoaded: (InterstitialAd ad) {
            AdStats.instance.interLoad.value++;
            AppLogger.log("inter loaded");
            _interstitialAd = ad;
            _interstitialAd!.setImmersiveMode(true);
            _isInterstitialAdLoaded = true;
          },

          /// Called if the ad fails to load.
          onAdFailedToLoad: (LoadAdError error) {
            AdStats.instance.interFailed.value++;
            _interstitialAd = null;
            _isInterstitialAdLoaded = false;
          },
        ),
      );
    } catch (error) {
      /// Disposes the ad if any error occurs.
      _interstitialAd?.dispose();
    }
  }

  /// Shows the interstitial ad if it's ready.
  ///
  /// Only shows the ad if the interstitial is loaded and the counter limit is reached.
  /// After showing the ad, it resets the counter and loads a new ad.
  void showInter({
    required Function({InterstitialAd? ad, AdError? error}) callBack,
  }) {
    if (shouldShowInterAd) {
      /// Check if the interstitial ad is loaded and if the counter limit has been reached.
      if (_isInterstitialAdLoaded &&
          _interstitialAd != null &&
          counter >= getInterCounter) {
        counter = 0;

        _interstitialAd!
          ..fullScreenContentCallback = FullScreenContentCallback(
            /// Called when the ad is dismissed.
            onAdDismissedFullScreenContent: (ad) {
              callBack(ad: ad);
              ad.dispose();
              _interstitialAd = null;
              load();
            },

            /// Called when an impression of the ad is recorded.
            onAdImpression: (_) {
              AdStats.instance.interImp.value++;
            },

            /// Called if the ad fails to show.
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

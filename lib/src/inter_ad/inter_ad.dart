import '../ad_internal.dart';

/// A singleton class to manage interstitial ads.
class InterAd with AdLoaderMixin {
  /// Singleton instance of [InterAd].
  static final InterAd instance = InterAd._internal();

  /// Factory constructor to provide access to the singleton [InterAd].
  factory InterAd() {
    return instance;
  }

  /// Private constructor for [InterAd] singleton.
  InterAd._internal();

  /// The interstitial ad object.
  InterstitialAd? _interstitialAd;

  /// Loads an interstitial ad.
  ///
  /// Attempts to load an interstitial ad and set its immersive mode when it's loaded.
  void load() {
    try {
      isAdLoaded = false;
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
            isAdLoaded = true;
          },

          /// Called if the ad fails to load.
          onAdFailedToLoad: (LoadAdError error) {
            AdStats.instance.interFailed.value++;
            _interstitialAd = null;
            handleLoadError("Interstitial", error);
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
      if (isAdLoaded &&
          _interstitialAd != null &&
          isLimitReached(getInterCounter)) {
        resetCounter();

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
        incrementCounter();
        callBack();
      }
    } else {
      callBack();
    }
  }
}

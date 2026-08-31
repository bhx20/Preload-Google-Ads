import '../ad_internal.dart';

/// A singleton class to manage interstitial ads.
class InterAd extends BaseAdLoader {
  /// Singleton instance of [InterAd].
  static final InterAd instance = InterAd._internal();

  /// Factory constructor to provide access to the singleton [InterAd].
  factory InterAd() {
    return instance;
  }

  /// Private constructor for [InterAd] singleton.
  InterAd._internal();

  @override
  bool get isEnabled => shouldShowInterAd;

  @override
  String get adLabel => "Interstitial";

  /// The interstitial ad object.
  InterstitialAd? _interstitialAd;

  /// Loads an interstitial ad.
  ///
  /// Attempts to load an interstitial ad and set its immersive mode when it's loaded.
  @override
  void load() {
    if (!prepareLoad()) return;
    try {
      InterstitialAd.load(
        adUnitId: unitIDInter,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          /// Called when the ad is loaded successfully.
          onAdLoaded: (InterstitialAd ad) {
            AdStats.instance.interLoad.value++;
            _interstitialAd = ad;
            _interstitialAd!.setImmersiveMode(true);
            handleLoadSuccess();
          },

          /// Called if the ad fails to load.
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            AdStats.instance.interFailed.value++;
            handleFailureAndRetry(error);
          },
        ),
      );
    } catch (error) {
      state = AdLoadState.failed;
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
    incrementCounter();
    if (counter < getInterCounter) {
      // Counter limit not reached yet. Do NOT waste ad request or show.
      callBack();
      return;
    }

    if (shouldShowInterAd && _interstitialAd != null && isAdLoaded) {
      // Check if ad expired (AdMob 4-hour TTL rule)
      if (isExpired) {
        AppLogger.warn('Interstitial ad expired. Fetching fresh ad.');
        _interstitialAd?.dispose();
        _interstitialAd = null;
        loadTime = null;
        state = AdLoadState.initial;
        load();
        callBack();
        return;
      }

      resetCounter();
      state = AdLoadState.showing;

      _interstitialAd!
        ..fullScreenContentCallback = FullScreenContentCallback(
          /// Called when the ad is dismissed.
          onAdDismissedFullScreenContent: (ad) {
            callBack(ad: ad as InterstitialAd?);
            ad.dispose();
            _interstitialAd = null;
            state = AdLoadState.initial;
            load();
          },

          /// Called when an impression of the ad is recorded.
          onAdImpression: (_) {
            AdStats.instance.interImp.value++;
          },

          /// Called if the ad fails to show.
          onAdFailedToShowFullScreenContent: (ad, error) {
            callBack(ad: ad as InterstitialAd?, error: error);
            AppLogger.error('$ad onAdFailedToShowFullScreenContent: $error');
            ad.dispose();
            _interstitialAd = null;
            state = AdLoadState.failed;
            load();
          },
        )
        ..show();
    } else {
      if (!isAdLoaded && state != AdLoadState.loading) {
        load(); // Request ad only when user is close/ready to view
      }
      callBack();
    }
  }

  /// Resets the ad state and disposes of loaded ads.
  @override
  void reset() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    super.reset();
  }
}

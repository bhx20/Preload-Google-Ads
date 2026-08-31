import '../ad_internal.dart';

/// Utility class that manages loading and showing app open ads.
class AppOpenAdManager extends BaseAdLoader {
  /// Singleton instance of [AppOpenAdManager].
  static final AppOpenAdManager instance = AppOpenAdManager._internal();

  /// Factory constructor providing access to the singleton [AppOpenAdManager].
  factory AppOpenAdManager() => instance;

  /// Private constructor for [AppOpenAdManager] singleton.
  AppOpenAdManager._internal();

  @override
  bool get isEnabled => shouldShowOpenAppAd;

  @override
  String get adLabel => "App Open";

  @override
  void load() {
    loadAd();
  }

  /// The ad object to hold the loaded app open ad.
  AppOpenAd? _appOpenAd;

  /// Flag to track if an ad is currently being shown.
  bool get _isShowingAd => isShowing;

  /// Load an [AppOpenAd].
  void loadAd() {
    if (!prepareLoad()) return;

    try {
      /// Attempt to load the App Open ad.
      AppOpenAd.load(
        adUnitId: unitIDAppOpen,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          /// Callback when the ad is successfully loaded.
          onAdLoaded: (ad) {
            AdStats.instance.openAppLoad.value++;
            _appOpenAd = ad;
            handleLoadSuccess();
          },

          /// Callback if the ad fails to load.
          onAdFailedToLoad: (error) {
            AdStats.instance.openAppFailed.value++;
            _appOpenAd = null;
            handleFailureAndRetry(error, onRetry: () => loadAd());
          },
        ),
      );
    } catch (error) {
      state = AdLoadState.failed;
      AppLogger.error('Exception during AppOpenAd load: $error');
    }
  }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null && isAdLoaded;
  }

  /// Shows the ad, if one exists and is not already being shown.
  ///
  /// If the previously cached ad has expired, this just loads and caches a
  /// new ad.
  void showAdIfAvailable() {
    if (!isEnabled) return;

    /// Check if an ad is available, if not, load a new one.
    if (!isAdAvailable) {
      AppLogger.log('Tried to show ad before available.');
      loadAd();
      return;
    }

    /// Check if the ad is already being shown, if so, do nothing.
    if (_isShowingAd) {
      AppLogger.warn('Tried to show ad while already showing an ad.');
      return;
    }

    /// Check if the cached ad has expired based on the max cache duration.
    if (isExpired) {
      AppLogger.warn('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadTime = null;
      loadAd();
      return;
    }

    state = AdLoadState.showing;

    /// Set the callback to handle the ad's full-screen content events.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      /// Callback when the ad is successfully shown.
      onAdShowedFullScreenContent: (ad) {
        AppLogger.log('$ad onAdShowedFullScreenContent');
      },

      /// Callback when the ad fails to show.
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.error('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _appOpenAd = null;
        state = AdLoadState.failed;
      },

      /// Callback when the ad impression is logged.
      onAdImpression: (value) {
        AdStats.instance.openAppImp.value++;
      },

      /// Callback when the ad is dismissed.
      onAdDismissedFullScreenContent: (ad) {
        AppLogger.log('$ad onAdDismissedFullScreenContent');
        ad.dispose();
        _appOpenAd = null;
        state = AdLoadState.initial;
        loadAd();
      },
    );

    /// Show the app open ad.
    _appOpenAd!.show();
  }

  @override
  void reset() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    loadTime = null;
    super.reset();
  }
}

import '../../preload_google_ads.dart';

/// Utility class that manages loading and showing app open ads.
class AppOpenAdManager {
  static final AppOpenAdManager instance = AppOpenAdManager._internal();

  /// Singleton pattern: ensuring only one instance of AppOpenAdManager exists.
  factory AppOpenAdManager() {
    return instance;
  }

  /// Private constructor to prevent external instantiation.
  AppOpenAdManager._internal();

  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  /// The ad object to hold the loaded app open ad.
  AppOpenAd? _appOpenAd;

  /// Flag to track if an ad is currently being shown.
  bool _isShowingAd = false;

  /// Load an [AppOpenAd].
  void loadAd() {
    try {
      /// Attempt to load the App Open ad.
      AppOpenAd.load(
        adUnitId: unitIDAppOpen,

        /// Use the appropriate ad unit ID.
        request: const AdRequest(),

        /// Request with default parameters.
        adLoadCallback: AppOpenAdLoadCallback(
          /// Callback when the ad is successfully loaded.
          onAdLoaded: (ad) {
            AdStats.instance.openAppLoad.value++;

            /// Increment the ad load counter.
            AppLogger.log('$ad loaded');

            /// Log that the ad was loaded successfully.
            _appOpenLoadTime = DateTime.now();

            /// Store the load time.
            _appOpenAd = ad;

            /// Store the loaded ad.
          },

          /// Callback if the ad fails to load.
          onAdFailedToLoad: (error) {
            AdStats.instance.openAppFailed.value++;

            /// Increment the failure counter.
            AppLogger.error('AppOpenAd failed to load: $error');

            /// Log the error.
          },
        ),
      );
    } catch (error) {
      /// If an error occurs during ad loading, attempt to load the ad again.
      loadAd();
    }
  }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  /// Shows the ad, if one exists and is not already being shown.
  ///
  /// If the previously cached ad has expired, this just loads and caches a
  /// new ad.
  void showAdIfAvailable() {
    /// Check if an ad is available, if not, load a new one.
    if (!isAdAvailable) {
      AppLogger.log('Tried to show ad before available.');
      loadAd();

      /// Load a new ad.
      return;
    }

    /// Check if the ad is already being shown, if so, do nothing.
    if (_isShowingAd) {
      AppLogger.warn('Tried to show ad while already showing an ad.');
      return;
    }

    /// Check if the cached ad has expired based on the max cache duration.
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      AppLogger.warn('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();

      /// Dispose of the expired ad.
      _appOpenAd = null;

      /// Set ad to null.
      loadAd();

      /// Load a new ad.
      return;
    }

    /// Set the callback to handle the ad's full-screen content events.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      /// Callback when the ad is successfully shown.
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;

        /// Set the flag indicating the ad is being shown.
        AppLogger.log('$ad onAdShowedFullScreenContent');

        /// Log ad showing.
      },

      /// Callback when the ad fails to show.
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.error('$ad onAdFailedToShowFullScreenContent: $error');

        /// Log error.
        _isShowingAd = false;

        /// Reset the flag.
        ad.dispose();

        /// Dispose of the ad object.
        _appOpenAd = null;

        /// Set ad to null.
      },

      /// Callback when the ad impression is logged.
      onAdImpression: (value) {
        AdStats.instance.openAppImp.value++;

        /// Increment the impression counter.
      },

      /// Callback when the ad is dismissed.
      onAdDismissedFullScreenContent: (ad) {
        AppLogger.log('$ad onAdDismissedFullScreenContent');

        /// Log that the ad was dismissed.
        _isShowingAd = false;

        /// Reset the flag.
        ad.dispose();

        /// Dispose of the ad.
        _appOpenAd = null;

        /// Set ad to null.
        loadAd();

        /// Load a new ad for the next time.
      },
    );

    /// Show the app open ad.
    _appOpenAd!.show();
  }
}

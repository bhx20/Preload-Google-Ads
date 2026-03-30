import '../ad_internal.dart';

/// A class responsible for loading and managing banner ads.
class LoadBannerAd {
  /// Singleton instance of LoadBannerAd.
  static final LoadBannerAd instance = LoadBannerAd._internal();

  /// Factory constructor to return the singleton instance.
  factory LoadBannerAd() {
    return instance;
  }

  /// Private constructor to prevent external instantiation.
  LoadBannerAd._internal();

  /// ValueNotifier that holds currently loaded and cached banner ads.
  final ValueNotifier<List<BannerAd>> bannerAds = ValueNotifier([]);

  /// Helper to get the list of ads directly.
  List<BannerAd> get _activeAds => bannerAds.value;

  /// Variable to control the retry/reload logic of the ad.
  int reloadAd = 1;

  /// The ad currently in the process of loading.
  BannerAd? _loadingAd;

  /// Flag to check if an ad is currently in the process of loading.
  bool loading = false;

  /// Loads a banner ad and handles its loading, errors, and impressions.
  ///
  /// If fewer than 2 banner ads are loaded, it will load additional ads.
  Future<void> loadAd() async {
    if (loading || _activeAds.length >= 2 || !shouldShowBannerAd) return;

    try {
      loading = true;
      // Get the current screen's physical size.
      final view = PlatformDispatcher.instance.implicitView;
      if (view == null) {
        loading = false;
        return;
      }

      final double logicalScreenWidth =
          view.physicalSize.width / view.devicePixelRatio;

      if (logicalScreenWidth <= 0) {
        loading = false;
        return;
      }

      // Get the appropriate size for the banner ad based on the screen width.
      final AnchoredAdaptiveBannerAdSize? size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        logicalScreenWidth.toInt(),
      );

      if (size == null) {
        loading = false;
        return;
      }

      // Create and configure the banner ad.
      late final BannerAd currentAd;
      currentAd = BannerAd(
        adUnitId: unitIDBanner,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            // Verify if this ad is still the one we were waiting for.
            // If _loadingAd is null or different, it means reset() was called
            // or another load was started, so we should dispose this ad.
            if (_loadingAd != currentAd) {
              AppLogger.warn("Ad loaded but was already replaced/reset. Disposing.");
              ad.dispose();
              return;
            }

            // Handle successful ad load.
            AppLogger.log('Banner Ad loaded: $ad');
            
            // Atomically update the list to trigger listeners.
            bannerAds.value = [..._activeAds, ad as BannerAd];
            
            _loadingAd = null;
            AdStats.instance.bannerLoad.value++;
            loading = false;
            // Load another ad if there are fewer than 2 loaded ads.
            if (_activeAds.length < 2) {
              Future.delayed(const Duration(seconds: 2), () => loadAd());
            }
          },
          onAdImpression: (ad) {
            // We now increment in takeAd() for more immediate feedback, 
            // but we can log the official SDK impression here.
            AppLogger.log("Banner Ad SDK Impression recorded.");
          },
          onAdOpened: (ad) {
            AppLogger.log("Banner Ad Opened.");
          },
          onAdClicked: (ad) {
            AppLogger.log("Banner Ad Clicked.");
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            // Handle failed ad load and retry logic.
            if (_loadingAd == currentAd) {
              _loadingAd = null;
              loading = false;
            }
            
            AdStats.instance.bannerFailed.value++;
            ad.dispose();
            
            // Only retry if we are still in a valid loading state.
            if (reloadAd == 1) {
              reloadAd--;
              loadAd();
              AppLogger.error("Failed Banner AD: ${error.message}");
            } else {
              reloadAd = 1;
            }
          },
        ),
      );

      _loadingAd = currentAd;

      // Load the banner ad.
      await currentAd.load();
    } catch (error) {
      // Catch and log any errors that occur during ad loading.
      _loadingAd?.dispose();
      _loadingAd = null;
      loading = false;
      AppLogger.error("catch error loading banner: $error");
    }
  }

  /// Takes the first available ad from the cache and notifies listeners.
  BannerAd? takeAd() {
    if (_activeAds.isEmpty) return null;
    final ads = List<BannerAd>.from(_activeAds);
    final ad = ads.removeAt(0);

    // Increment impression count and update the list.
    // Wrap in microtask to avoid "setState() or markNeedsBuild() called during build"
    // which happens when updating notifiers during the widget build phase (e.g. initState).
    Future.microtask(() {
      bannerAds.value = ads;
      AdStats.instance.bannerImp.value++;
      AppLogger.log("Banner Ad consumed from cache. Show count incremented.");
    });
    
    return ad;
  }

  /// Disposes of all loaded ads and resets the state.
  void reset() {
    _loadingAd?.dispose();
    _loadingAd = null;
    for (final ad in _activeAds) {
      ad.dispose();
    }
    bannerAds.value = [];
    loading = false;
    reloadAd = 1;
  }
}

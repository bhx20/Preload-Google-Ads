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

  /// List that holds loaded banner ads.
  /// List that holds currently loaded and cached banner ads.
  List<BannerAd> bannerAdObject = [];

  /// Variable to control the retry/reload logic of the ad.
  int reloadAd = 1;

  /// Flag to check if an ad is currently in the process of loading.
  bool loading = false;

  /// Loads a banner ad and handles its loading, errors, and impressions.
  ///
  /// If fewer than 2 banner ads are loaded, it will load additional ads.
  Future<void> loadAd() async {
    if (loading || bannerAdObject.length >= 2) return;

    BannerAd? bannerAd;

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
      bannerAd = BannerAd(
        adUnitId: unitIDBanner,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            // Handle successful ad load.
            AppLogger.log('$ad loaded.');
            if (bannerAd != null) {
              bannerAdObject.add(bannerAd);
            }
            AdStats.instance.bannerLoad.value++;
            loading = false;
            // Load another ad if there are fewer than 2 loaded ads.
            if (bannerAdObject.length < 2) {
              Future.delayed(const Duration(seconds: 2), () => loadAd());
            }
          },
          onAdImpression: (ad) {
            // Track ad impressions.
            AdStats.instance.bannerImp.value++;
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            // Handle failed ad load and retry logic.
            loading = false;
            AdStats.instance.bannerFailed.value++;
            ad.dispose();
            if (reloadAd == 1) {
              reloadAd--;
              loadAd();
              AppLogger.error("Failed Banner AD");
              AppLogger.error(error.toString());
            } else {
              reloadAd = 1;
            }
          },
        ),
      );

      // Load the banner ad.
      await bannerAd.load();
    } catch (error) {
      // Catch and log any errors that occur during ad loading.
      loading = false;
      AppLogger.error("catch error loading banner");
      AppLogger.error(error.toString());
    }
  }

  /// Disposes of all loaded ads and resets the state.
  void reset() {
    for (final ad in bannerAdObject) {
      ad.dispose();
    }
    bannerAdObject.clear();
    loading = false;
    reloadAd = 1;
  }
}

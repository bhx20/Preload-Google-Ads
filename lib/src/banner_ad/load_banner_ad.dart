import '../ad_internal.dart';

/// A class responsible for loading and managing banner ads.
class LoadBannerAd extends BaseAdLoader {
  /// Singleton instance of LoadBannerAd.
  static final LoadBannerAd instance = LoadBannerAd._internal();

  /// Factory constructor to return the singleton instance.
  factory LoadBannerAd() => instance;

  /// Private constructor to prevent external instantiation.
  LoadBannerAd._internal();

  @override
  bool get isEnabled => shouldShowBannerAd;

  @override
  String get adLabel => "Banner";

  /// List that holds currently loaded and cached banner ads.
  List<BannerAd> bannerAdObject = [];

  /// Legacy loading getter for backward compatibility.
  bool get loading => isLoading;

  /// Legacy reloadAd getter for backward compatibility.
  int get reloadAd => retryAttempts;

  @override
  void load() {
    loadAd();
  }

  /// Loads a banner ad (standard or collapsible) and handles its loading, errors, and impressions.
  ///
  /// Specify [isCollapsible] as 'bottom' or 'top' for collapsible banner ads.
  Future<void> loadAd({String? isCollapsible}) async {
    if (bannerAdObject.length >= 2 || !prepareLoad()) return;

    BannerAd? bannerAd;

    try {
      // Get the current screen's physical size.
      final view = PlatformDispatcher.instance.implicitView;
      if (view == null) {
        state = AdLoadState.failed;
        return;
      }

      final double logicalScreenWidth =
          view.physicalSize.width / view.devicePixelRatio;

      if (logicalScreenWidth <= 0) {
        state = AdLoadState.failed;
        return;
      }

      // Get the appropriate size for the banner ad based on the screen width.
      final AnchoredAdaptiveBannerAdSize? size =
          await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
        logicalScreenWidth.toInt(),
      );

      if (size == null) {
        state = AdLoadState.failed;
        return;
      }

      // Configure request extras for Collapsible Banner if specified.
      final AdRequest request = isCollapsible != null
          ? AdRequest(
              extras: <String, String>{
                'collapsible': isCollapsible,
                'collapsible_request_id': DateTime.now().millisecondsSinceEpoch.toString(),
              },
            )
          : const AdRequest();

      // Create and configure the banner ad.
      bannerAd = BannerAd(
        adUnitId: unitIDBanner,
        size: size,
        request: request,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            // Handle successful ad load.
            if (bannerAd != null) {
              bannerAdObject.add(bannerAd);
            }
            AdStats.instance.bannerLoad.value++;
            handleLoadSuccess();
            // Load another ad if there are fewer than 2 loaded ads.
            if (bannerAdObject.length < 2) {
              scheduleReload(const Duration(seconds: 2), () => loadAd(isCollapsible: isCollapsible));
            }
          },
          onAdImpression: (ad) {
            // Track ad impressions.
            AdStats.instance.bannerImp.value++;
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            // Handle failed ad load and retry logic.
            AdStats.instance.bannerFailed.value++;
            ad.dispose();
            handleFailureAndRetry(error, onRetry: () => loadAd(isCollapsible: isCollapsible));
          },
        ),
      );

      // Load the banner ad.
      await bannerAd.load();
    } catch (error) {
      // Catch and log any errors that occur during ad loading.
      state = AdLoadState.failed;
      AppLogger.error("catch error loading banner: $error");
    }
  }

  /// Disposes of all loaded ads and resets the state.
  @override
  void reset() {
    for (final ad in bannerAdObject) {
      ad.dispose();
    }
    bannerAdObject.clear();
    super.reset();
  }
}

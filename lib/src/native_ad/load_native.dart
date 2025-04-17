import '../../preload_google_ads.dart';

///==============================================================================
///   ** Large Native ***
///==============================================================================

/// A singleton class that loads large native ads.
class LoadMediumNative {
  static final LoadMediumNative instance = LoadMediumNative._internal();

  factory LoadMediumNative() {
    return instance;
  }

  LoadMediumNative._internal();

  /// List to store the loaded large native ads.
  List<NativeAd> nativeObjectLarge = [];

  /// Reload control for large native ads.
  int reloadAd = 1;

  /// A flag to track if an ad is currently loading.
  bool loading = false;

  /// Loads a large native ad.
  ///
  /// Attempts to load the ad and add it to the list of loaded native ads.
  /// It will reload the ad if the loading fails or if there are fewer than two ads loaded.
  Future<void> loadAd() async {
    NativeAd? nativeAd;

    if (nativeObjectLarge.length <= 2) {
      try {
        loading = true;
        // Create a new native ad.
        nativeAd = NativeAd(
          factoryId: factoryIdMediumNative,
          adUnitId: unitIDNative,
          listener: NativeAdListener(
            /// Called when the ad is loaded.
            onAdLoaded: (ad) async {
              AppLogger.log('$NativeAd loaded.');
              if (nativeAd != null) {
                nativeObjectLarge.add(nativeAd);
              }
              // If fewer than two ads are loaded, load another.
              if (nativeObjectLarge.length < 2) {
                loadAd();
              }
              AdStats.instance.nativeLoadM.value++;
              loading = false;
            },

            /// Called when the ad impression is recorded.
            onAdImpression: (add) {
              AdStats.instance.nativeImpM.value++;
            },

            /// Called when the ad fails to load.
            onAdFailedToLoad: (ad, error) {
              loading = false;
              AdStats.instance.nativeFailedM.value++;
              ad.dispose();
              if (reloadAd == 1) {
                reloadAd--;
                loadAd();
                AppLogger.error("failed ad large");
                AppLogger.error(error.toString());
              } else {
                reloadAd = 1;
              }
            },
          ),
          request: const AdRequest(),
        );
        await nativeAd.load();
      } catch (error) {
        AppLogger.error("catch error");
        AppLogger.error(error.toString());
      }
    }
  }
}

///==============================================================================
///   ** Small Native ***
///==============================================================================

/// A singleton class that loads small native ads.
class LoadSmallNative {
  static final LoadSmallNative instance = LoadSmallNative._internal();

  factory LoadSmallNative() {
    return instance;
  }

  LoadSmallNative._internal();

  /// List to store the loaded small native ads.
  List<NativeAd> nativeObjectSmall = [];

  /// Reload control for small native ads.
  int reloadAd = 1;

  /// A flag to track if an ad is currently loading.
  bool loading = false;

  /// Loads a small native ad.
  ///
  /// Attempts to load the ad and add it to the list of loaded native ads.
  /// It will reload the ad if the loading fails or if there are fewer than two ads loaded.
  Future<void> loadAd() async {
    NativeAd? nativeAd;
    if (nativeObjectSmall.length <= 2) {
      loading = true;
      try {
        // Create a new native ad.
        nativeAd = NativeAd(
          factoryId: factoryIdSmallNative,
          adUnitId: unitIDNative,
          listener: NativeAdListener(
            /// Called when the ad is loaded.
            onAdLoaded: (ad) async {
              if (nativeAd != null) {
                nativeObjectSmall.add(nativeAd);
              }
              // If fewer than two ads are loaded, load another.
              if (nativeObjectSmall.length < 2) {
                await loadAd();
              }
              AdStats.instance.nativeLoadS.value++;
              loading = false;
            },

            /// Called when the ad impression is recorded.
            onAdImpression: (ad) {
              AdStats.instance.nativeImpS.value++;
            },

            /// Called when the ad fails to load.
            onAdFailedToLoad: (ad, error) {
              loading = false;
              AdStats.instance.nativeFailedS.value++;
              ad.dispose();
              if (reloadAd == 1) {
                reloadAd--;
                loadAd();
              } else {
                reloadAd = 1;
              }
            },
          ),
          request: const AdRequest(),
        );

        await nativeAd.load();
      } catch (error) {
        AppLogger.error("catch error");
        AppLogger.error(error.toString());
      }
    }
  }
}

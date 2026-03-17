import '../ad_internal.dart';

/// Base class for loading native ads to reduce code duplication.
abstract class BaseNativeAdLoader {
  /// List to store the loaded native ads.
  List<NativeAd> ads = [];

  /// Reload control for native ads.
  int reloadAdCount = 1;

  /// A flag to track if an ad is currently loading.
  /// Whether an ad is currently being loaded.
  bool isLoading = false;

  /// Abstract getters for ad-specific configuration.
  /// The factory ID to use for this ad loader.
  String? get factoryId;

  /// The template style to use for this ad loader.
  NativeTemplateStyle? get templateStyle;

  /// The stats for loaded ads.
  ValueNotifier<int> get loadStats;

  /// The stats for ad impressions.
  ValueNotifier<int> get impStats;

  /// The stats for failed ad loads.
  ValueNotifier<int> get failedStats;

  /// The human-readable label for this ad type.
  String get adTypeLabel;

  /// Loads a native ad.
  Future<void> loadAd() async {
    if (ads.length > 2) return;

    try {
      isLoading = true;
      NativeAd? nativeAd;
      nativeAd = NativeAd(
        factoryId: factoryId,
        adUnitId: unitIDNative,
        nativeTemplateStyle: templateStyle,
        listener: NativeAdListener(
          onAdLoaded: (ad) async {
            AppLogger.log('$adTypeLabel ad loaded.');
            if (nativeAd != null) {
              ads.add(nativeAd);
            }
            if (ads.length < 2) {
              loadAd();
            }
            loadStats.value++;
            isLoading = false;
          },
          onAdImpression: (ad) {
            impStats.value++;
          },
          onAdFailedToLoad: (ad, error) {
            isLoading = false;
            failedStats.value++;
            ad.dispose();
            if (reloadAdCount == 1) {
              reloadAdCount--;
              loadAd();
              AppLogger.error("Failed to load $adTypeLabel ad: $error");
            } else {
              reloadAdCount = 1;
            }
          },
        ),
        request: const AdRequest(),
      );
      await nativeAd.load();
    } catch (error) {
      AppLogger.error("Error in $adTypeLabel ad load catch: $error");
    }
  }

  /// Disposes of all loaded ads and resets the state.
  void reset() {
    for (final ad in ads) {
      ad.dispose();
    }
    ads.clear();
    isLoading = false;
    reloadAdCount = 1;
  }
}

///==============================================================================
///   ** Medium Native ***
///==============================================================================

/// A singleton class that loads medium native ads.
class LoadMediumNative extends BaseNativeAdLoader {
  /// Singleton instance of [LoadMediumNative].
  static final LoadMediumNative instance = LoadMediumNative._internal();

  /// Factory constructor to provide access to the singleton [LoadMediumNative].
  factory LoadMediumNative() => instance;

  /// Private constructor for [LoadMediumNative] singleton.
  LoadMediumNative._internal();

  @override
  String? get factoryId => NativeADStyle.instance.mediumNativeFactoryId;

  @override
  NativeTemplateStyle? get templateStyle =>
      NativeADStyle.instance.nativeMediumTemplateStyle;

  /// Statistics for medium native ad loads.
  @override
  ValueNotifier<int> get loadStats => AdStats.instance.nativeLoadM;

  /// Statistics for medium native ad impressions.
  @override
  ValueNotifier<int> get impStats => AdStats.instance.nativeImpM;

  /// Statistics for medium native ad load failures.
  @override
  ValueNotifier<int> get failedStats => AdStats.instance.nativeFailedM;
  @override
  String get adTypeLabel => "Medium Native";

  /// Compatibility getter for existing code to access medium native ads.
  List<NativeAd> get nativeObjectLarge => ads;
}

///==============================================================================
///   ** Small Native ***
///==============================================================================

/// A singleton class that loads small native ads.
class LoadSmallNative extends BaseNativeAdLoader {
  /// Singleton instance of [LoadSmallNative].
  static final LoadSmallNative instance = LoadSmallNative._internal();

  /// Factory constructor to provide access to the singleton [LoadSmallNative].
  factory LoadSmallNative() => instance;

  /// Private constructor for [LoadSmallNative] singleton.
  LoadSmallNative._internal();

  @override
  String? get factoryId => NativeADStyle.instance.smallNativeFactoryId;

  @override
  NativeTemplateStyle? get templateStyle =>
      NativeADStyle.instance.nativeSmallTemplateStyle;

  /// Statistics for small native ad loads.
  @override
  ValueNotifier<int> get loadStats => AdStats.instance.nativeLoadS;

  /// Statistics for small native ad impressions.
  @override
  ValueNotifier<int> get impStats => AdStats.instance.nativeImpS;

  /// Statistics for small native ad load failures.
  @override
  ValueNotifier<int> get failedStats => AdStats.instance.nativeFailedS;

  /// Label for small native ads.
  @override
  String get adTypeLabel => "Small Native";

  /// Compatibility getter for existing code to access small native ads.
  List<NativeAd> get nativeObjectSmall => ads;
}

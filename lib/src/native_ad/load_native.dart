import '../ad_internal.dart';

/// Base class for loading native ads to reduce code duplication.
abstract class BaseNativeAdLoader {
  /// List to store the loaded native ads.
  List<NativeAd> ads = [];

  /// List to store the assets for each loaded native ad.
  List<NativeAdAssets> adAssets = [];

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

  /// The ad unit ID to use (defaults to global native unit ID).
  String get customAdUnitId => unitIDNative;

  /// Loads a native ad.
  Future<void> loadAd() async {
    if (isLoading || ads.length >= 2) return;

    try {
      isLoading = true;
      NativeAd? nativeAd;
      nativeAd = NativeAd(
        factoryId: factoryId,
        adUnitId: customAdUnitId,
        nativeTemplateStyle: templateStyle,
        nativeAdOptions: NativeAdOptions(
          videoOptions: VideoOptions(
            startMuted: true,
            customControlsRequested: false,
          ),
          adChoicesPlacement: AdChoicesPlacement.topRightCorner,
          mediaAspectRatio: MediaAspectRatio.any,
        ),
        listener: NativeAdListener(
          onAdLoaded: (ad) async {
            AppLogger.log('$adTypeLabel ad loaded.');
            if (nativeAd != null) {
              ads.add(nativeAd);
            }
            loadStats.value++;
            isLoading = false;
            // Native side will send assets via MethodChannel separately
            if (ads.length < 2) {
              Future.delayed(const Duration(seconds: 1), () => loadAd());
            }
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
      isLoading = false;
      AppLogger.error("Error in $adTypeLabel ad load catch: $error");
    }
  }

  /// Disposes of all loaded ads and resets the state.
  void reset() {
    for (final ad in ads) {
      ad.dispose();
    }
    ads.clear();
    adAssets.clear();
    isLoading = false;
    reloadAdCount = 1;
  }
}


///==============================================================================
///   ** Dynamic Native Manager ***
///==============================================================================

/// Manages multiple custom native ad factories and their preloaded ads.
class DynamicNativeLoaderManager {
  /// Singleton instance of [DynamicNativeLoaderManager].
  static final DynamicNativeLoaderManager instance =
      DynamicNativeLoaderManager._internal();

  /// Private constructor for singleton pattern.
  DynamicNativeLoaderManager._internal();

  /// Map to store loaders by their factory ID.
  final Map<String, DynamicNativeAdLoader> _loaders = {};

  /// Returns all registered loaders.
  Map<String, DynamicNativeAdLoader> get loaders => _loaders;

  /// Registers a new factory or updates an existing one.
  void registerFactory(NativeAdFactoryConfig config) {
    if (!_loaders.containsKey(config.factoryId)) {
      if (config.isBuilder) {
        _loaders[config.factoryId] = DynamicBuilderAdLoader(
          config: config,
          label: "Dynamic Builder (${config.factoryId})",
        );
      } else {
        _loaders[config.factoryId] = DynamicNativeAdLoader(
          config: config,
          label: "Dynamic Native (${config.factoryId})",
        );
      }
    } else {
      _loaders[config.factoryId]!.updateConfig(config);
    }
  }

  /// Loads ads for all registered factories.
  void loadAll() {
    for (final loader in _loaders.values) {
      loader.loadAd();
    }
  }

  /// Returns the loader for the specified [factoryId].
  DynamicNativeAdLoader? getLoader(String factoryId) {
    return _loaders[factoryId];
  }

  /// Returns a preloaded ad for the specified [factoryId], or null if none available.
  NativeAd? getAd(String factoryId) {
    final loader = _loaders[factoryId];
    if (loader != null && loader.ads.isNotEmpty) {
      final ad = loader.ads.removeAt(0);
      loader.loadAd(); // Refill the pool
      return ad;
    }
    return null;
  }

  /// Resets all dynamic loaders.
  void resetAll() {
    for (final loader in _loaders.values) {
      loader.reset();
    }
  }
}

/// A flexible native ad loader for dynamic factory support.
class DynamicNativeAdLoader extends BaseNativeAdLoader {
  NativeAdFactoryConfig _config;
  final String _label;

  /// Stats for this specific dynamic loader.
  final ValueNotifier<int> _loadStats = ValueNotifier(0);
  final ValueNotifier<int> _impStats = ValueNotifier(0);
  final ValueNotifier<int> _failedStats = ValueNotifier(0);

  late String _resolvedAdUnitId;

  /// Constructor for [DynamicNativeAdLoader].
  DynamicNativeAdLoader({
    required NativeAdFactoryConfig config,
    required String label,
  })  : _config = config,
        _label = label {
    _resolvedAdUnitId = config.adUnitId ?? unitIDNative;
  }

  /// Updates the configuration for this loader.
  void updateConfig(NativeAdFactoryConfig config) {
    final oldId = _resolvedAdUnitId;
    _config = config;
    _resolvedAdUnitId = config.adUnitId ?? unitIDNative;

    // If the ad unit ID changed, the preloaded ads in the queue are potentially
    // for the wrong unit ID. Clear them so they are refilled with the correct ID.
    if (oldId != _resolvedAdUnitId) {
      AppLogger.log("Ad unit ID changed for $adTypeLabel. Clearing preloaded queue.");
      reset();
    }
  }

  /// Returns the current configuration.
  NativeAdFactoryConfig get config => _config;

  @override
  String? get factoryId => _config.factoryId;

  @override
  String get customAdUnitId => _resolvedAdUnitId;

  @override
  NativeTemplateStyle? get templateStyle => null;

  @override
  ValueNotifier<int> get loadStats => _loadStats;

  @override
  ValueNotifier<int> get impStats => _impStats;

  @override
  ValueNotifier<int> get failedStats => _failedStats;

  @override
  String get adTypeLabel => _label;
}

/// A flexible native ad loader specifically for builder-pattern custom ads.
/// 
/// Instead of using the google_mobile_ads NativeAd object, this delegates
/// the actual loading to the native builder cache while maintaining 
/// Dart-side queue control (max 2) and statistics tracking.
class DynamicBuilderAdLoader extends DynamicNativeAdLoader {
  int _preloadedCount = 0;

  /// Constructor for [DynamicBuilderAdLoader].
  DynamicBuilderAdLoader({
    required super.config,
    required super.label,
  });

  @override
  Future<void> loadAd() async {
    // We maintain a maximum queue of 2 preloaded ads on the native side.
    if (isLoading || _preloadedCount >= 2) return;

    try {
      isLoading = true;
      // Trigger the native-side preload.
      // We pass the factoryId so native can route assets back properly.
      const channel = MethodChannel(nativeChannel);
      await channel.invokeMethod('preloadBuilderAd', {
        'adUnitId': customAdUnitId,
        'factoryId': factoryId,
      });
      
      isLoading = false;
      AppLogger.log("Triggered native preload for $adTypeLabel");
      
      // Unlike standard ads, native handles loading completely.
      // We only increment load stats when we receive onAdAssetsLoaded,
      // which is handled in ad_manager.dart's channel listener.
    } catch (error) {
      isLoading = false;
      AppLogger.error("Error in $adTypeLabel ad load catch: $error");
    }
  }

  /// Called by the channel listener when native successfully preloads an ad.
  void onAdPreloadSuccess() {
    isLoading = false;
    _preloadedCount++;
    loadStats.value++;
    AppLogger.log('$adTypeLabel ad preloaded natively. Queue: $_preloadedCount/2');
    
    // Auto-refill logic to maintain 2 preloaded ads in the queue
    if (_preloadedCount < 2) {
      Future.delayed(const Duration(seconds: 1), () => loadAd());
    }
  }

  /// Called by the channel listener when native fails to preload an ad.
  void onAdPreloadFailure() {
    isLoading = false;
    failedStats.value++; // Increment failure counter
    AppLogger.error("$adTypeLabel preload failed. Retrying in 5s...");

    // Retry with backoff to increase chances of getting a fill
    Future.delayed(const Duration(seconds: 5), () => loadAd());
  }

  /// Called by CustomNativeAdView when it claims a preloaded ad.
  void consumePreloadedAd() {
    if (_preloadedCount > 0) {
      _preloadedCount--;
      impStats.value++; // Increment impression counter
      AppLogger.log('$adTypeLabel ad consumed. Queue: $_preloadedCount/2');
    }
    // Refill the queue now that an ad was consumed
    loadAd();
  }

  @override
  void reset() {
    _preloadedCount = 0;
    super.reset();
  }
}

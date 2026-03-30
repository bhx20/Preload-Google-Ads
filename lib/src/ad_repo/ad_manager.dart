import '../ad_internal.dart';

/// Singleton class responsible for managing all ad operations.
class AdManager {
  /// Singleton instance of AdManager
  static final AdManager _instance = AdManager._internal();

  /// Factory constructor to provide access to the single instance of AdManager
  factory AdManager() => _instance;

  /// Private named constructor to ensure only one instance is created
  AdManager._internal();

  /// Getter for the singleton instance of AdManager
  static AdManager get instance => _instance;

  /// The current ad configuration
  late AdConfigData config;

  /// Callback for splash ad
  Function(AppOpenAd? ad, AdError? error)? _splashAdCallback;

  /// Initializes the AdManager with the provided ad configuration.
  /// It also initializes mobile ads and loads the required ads based on the configuration.
  Future<void> initialize(AdConfigData? adConfig) async {
    // Reset any existing ad state before initializing with new config
    PlugAd.getInstance().resetAll();

    // Set the ad configuration data
    config = await setConfigData(adConfig);

    // Initialize the Google Mobile Ads SDK
    final initStatus = await MobileAds.instance.initialize();

    // Log adapter initialization status for diagnostics
    initStatus.adapterStatuses.forEach((adapter, status) {
      AppLogger.log(
        'Adapter: $adapter — ${status.state.name} (${status.description})',
      );
    });

    // Register test devices to get test ads on physical devices.
    // Without this, test ad unit IDs may return "Invalid Request" on real devices.
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: [
          // Add test device IDs as needed.
          // On iOS, check Xcode console for: "<Google> To get test ads on this device, set..."
        ],
      ),
    );

    // Setup MethodChannel for receiving assets from native
    _setupMethodChannel();

    // Load and show ads if required
    if (shouldShowAd) {
      _loadAndShowSplashAd();
      _loadBannerAd();
      _loadOpenAppAd();
      _loadInterAd();
      _loadRewardedAd();
      _loadCustomNativeAds();
    }
  }

  /// Sets up the MethodChannel to receive ad assets and other events from native.
  void _setupMethodChannel() {
    const channel = MethodChannel(nativeChannel);
    channel.setMethodCallHandler((call) async {
      if (call.method == 'onAdAssetsLoaded') {
        final data = call.arguments as Map<dynamic, dynamic>;
        final factoryId = data['factoryId'] as String?;
        if (factoryId != null) {
          final assets = NativeAdAssets.fromMap(data);
          
          final loader = DynamicNativeLoaderManager.instance.getLoader(factoryId);

          if (loader != null) {
            loader.adAssets.add(assets);
            if (loader is DynamicBuilderAdLoader) {
              loader.onAdPreloadSuccess();
            }
            AppLogger.log("Assets received for factory: $factoryId");
          }
        }
      }
    });
  }

  /// Registers and loads custom native ads if provided in the configuration.
  void _loadCustomNativeAds() {
    if (config.adIDs?.customFactories != null) {
      for (final factory in config.adIDs!.customFactories!) {
        // All custom native ads (builder-only) now go through
        // the DynamicNativeLoaderManager for queue management and stats.
        DynamicNativeLoaderManager.instance.registerFactory(factory);
      }
      DynamicNativeLoaderManager.instance.loadAll();
    }
  }

  /// Preloads a builder-pattern native ad on the native side.
  Future<void> preloadBuilderAd({
    required String adUnitId,
    required String factoryId,
  }) async {
    const channel = MethodChannel(nativeChannel);
    try {
      await channel.invokeMethod('preloadBuilderAd', {
        'adUnitId': adUnitId,
        'factoryId': factoryId,
      });
    } catch (e) {
      AppLogger.log("Failed to preload builder ad: $e");
    }
  }

  /// Loads and shows the splash ad if enabled in the ad configuration.
  /// Calls the provided callback when the ad is ready or fails to load.
  void _loadAndShowSplashAd() {
    if (shouldShowSplashAd) {
      // Show the splash ad if enabled
      PlugAd.getInstance().showOpenAppOnSplash(
        callBack: ({AppOpenAd? ad, AdError? error}) {
          /// Invoke the splash ad callback with the ad or error
          _splashAdCallback?.call(ad, error);

          /// Reset the callback after it has been called
          _splashAdCallback = null;
        },
      );
    } else {
      /// If splash ad isn't enabled, reset the callback
      _splashAdCallback?.call(null, null);
      _splashAdCallback = null;
    }
  }


  /// Loads a banner ad if enabled in the ad configuration.
  void _loadBannerAd() {
    if (shouldShowBannerAd) {
      PlugAd.getInstance().loadBannerAd();
    }
  }

  /// Loads the open app ad if enabled in the ad configuration.
  void _loadOpenAppAd() {
    if (shouldShowOpenAppAd) {
      PlugAd.getInstance().loadAppOpenAd();
    }
  }

  /// Loads the interstitial ad if enabled in the ad configuration.
  void _loadInterAd() {
    if (shouldShowInterAd) {
      PlugAd.getInstance().loadInterAd();
    }
  }

  /// Loads the rewarded ad if enabled in the ad configuration.
  void _loadRewardedAd() {
    if (shouldShowRewardedAd) {
      PlugAd.getInstance().loadRewardedAd();
    }
  }

  /// Sets the callback function to be invoked when the splash ad is ready or fails.
  void setSplashAdCallback(Function(AppOpenAd? ad, AdError? error) callback) {
    _splashAdCallback = callback;
  }

  /// Below methods are used to show various types of ads


  /// Shows the open app ad.
  void showOpenApp() {
    return PlugAd.getInstance().showOpenAppAd();
  }

  /// Shows the banner ad.
  Widget showBannerAd() {
    return PlugAd.getInstance().showBannerAd();
  }

  /// Displays the ad counter (if available).
  Widget showAdCounter({bool? showCounter}) {
    return PlugAd.getInstance().showAdCounter(showCounter ?? true);
  }

  /// Shows the interstitial ad and invokes the provided callback with the ad or error.
  void showInterstitialAd({
    required Function(InterstitialAd? ad, AdError? error) callBack,
  }) {
    return PlugAd.getInstance().showInterAd(
      callBack: ({InterstitialAd? ad, AdError? error}) {
        callBack(ad, error);
      },
    );
  }

  /// Shows the rewarded ad and invokes the provided callbacks with the ad, error, and reward information.
  void showRewardedAd({
    required void Function(RewardedAd? ad, AdError? error) callBack,
    required void Function(AdWithoutView ad, RewardItem reward) onReward,
  }) {
    return PlugAd.getInstance().showRewardedAd(
      callBack: ({RewardedAd? ad, AdError? error}) {
        callBack(ad, error);
      },
      onReward: onReward,
    );
  }
}

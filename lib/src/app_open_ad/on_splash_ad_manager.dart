import '../../preload_google_ads.dart';

/// A utility class that manages loading and showing app open ads on splash screens.
class GoogleAppOpenOnSplash {
  /// Singleton instance of GoogleAppOpenOnSplash.
  static final GoogleAppOpenOnSplash instance =
      GoogleAppOpenOnSplash._internal();

  /// Factory constructor to return the singleton instance.
  factory GoogleAppOpenOnSplash() {
    return instance;
  }

  /// Private constructor to prevent external instantiation.
  GoogleAppOpenOnSplash._internal();

  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Track the load time to avoid showing an expired ad.
  DateTime? _appOpenLoadTime;

  /// The loaded AppOpenAd instance.
  AppOpenAd? _appOpenAd;

  /// Flag to track if an ad is being shown.
  bool _isShowingAd = false;

  /// A timer used to delay the callback execution for splash ad loading.
  late Timer _timer;

  /// Load and show an AppOpenAd on the splash screen.
  ///
  /// If the ad is successfully loaded, it will be shown immediately.
  /// If the ad fails to load, a fallback callback is invoked.
  Future<void> loadAndShowSplashAd({
    required Function({AppOpenAd? ad, AdError? error}) callBack,
  }) async {
    _timer = Timer.periodic(const Duration(seconds: 15), (Timer t) async {
      _timer.cancel();
      await callBack();
    });
    try {
      // Load the AppOpenAd using the provided ad unit ID and request.
      AppOpenAd.load(
        adUnitId: unitIDAppOpen,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            AdStats.instance.openAppLoad.value++;
            _timer.cancel();
            AppLogger.log('$ad loaded');
            _appOpenLoadTime = DateTime.now();
            _appOpenAd = ad;
            showAdIfAvailable(
              callBack: ({AppOpenAd? ad, AdError? error}) {
                callBack(ad: ad, error: error);
              },
            );
          },
          onAdFailedToLoad: (error) async {
            AdStats.instance.openAppFailed.value++;
            await callBack();
            AppLogger.error('AppOpenAd failed to load: $error');
          },
        ),
      );
    } on PlatformException {
      _timer.cancel();
      await callBack();
    } catch (error) {
      _timer.cancel();
      await callBack();
    }
  }

  /// Checks whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  /// Shows the app open ad if available and not already being shown.
  ///
  /// If the previously cached ad has expired, a new ad will be loaded and shown.
  void showAdIfAvailable({
    required Function({AppOpenAd? ad, AdError? error}) callBack,
  }) {
    if (!isAdAvailable) {
      AppLogger.log('Tried to show ad before available.');
      loadAndShowSplashAd(
        callBack: ({AppOpenAd? ad, AdError? error}) {
          callBack(ad: ad, error: error);
        },
      );
      return;
    }
    if (_isShowingAd) {
      AppLogger.warn('Tried to show ad while already showing an ad.');
      return;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      AppLogger.error('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAndShowSplashAd(
        callBack: ({AppOpenAd? ad, AdError? error}) {
          callBack(ad: ad, error: error);
        },
      );
      return;
    }

    // Set the full-screen content callback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        AppLogger.log('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        callBack(ad: ad, error: error);
        AppLogger.error('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdImpression: (value) {
        AdStats.instance.openAppImp.value++;
      },
      onAdDismissedFullScreenContent: (ad) {
        callBack(ad: ad);
        AppLogger.log('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
    );
    _appOpenAd!.show();
  }
}

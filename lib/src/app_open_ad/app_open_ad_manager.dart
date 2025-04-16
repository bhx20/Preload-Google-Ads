import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../preload_google_ads.dart';

/// Utility class that manages loading and showing app open ads.
class AppOpenAdManager {
  static final AppOpenAdManager instance = AppOpenAdManager._internal();

  factory AppOpenAdManager() {
    return instance;
  }

  AppOpenAdManager._internal();

  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  /// Load an [AppOpenAd].
  void loadAd() {
    try {
      AppOpenAd.load(
        adUnitId: PreloadGoogleAds.instance.initialData.appOpenId,

        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            AdStats.instance.openAppLoad.value++;
            AppLogger.log('$ad loaded');
            _appOpenLoadTime = DateTime.now();
            _appOpenAd = ad;
          },
          onAdFailedToLoad: (error) {
            AdStats.instance.openAppFailed.value++;
            AppLogger.error('AppOpenAd failed to load: $error');
          },
        ),
      );
    } catch (error) {
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
    if (!isAdAvailable) {
      AppLogger.log('Tried to show ad before available.');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      AppLogger.warn('Tried to show ad while already showing an ad.');
      return;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      AppLogger.warn('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAd();
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        AppLogger.log('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.error('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdImpression: (value) {
        AdStats.instance.openAppImp.value++;
      },
      onAdDismissedFullScreenContent: (ad) {
        AppLogger.log('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
    _appOpenAd!.show();
  }
}

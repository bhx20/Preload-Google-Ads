import 'dart:async';

import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../preload_google_ads.dart';

class GoogleAppOpenOnSplash {
  static final GoogleAppOpenOnSplash instance =
      GoogleAppOpenOnSplash._internal();

  factory GoogleAppOpenOnSplash() {
    return instance;
  }

  GoogleAppOpenOnSplash._internal();

  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  late Timer _timer;

  /// Load an [AppOpenAd].
  Future<void> loadAndShowSplashAd({
    required Function() onAdStartAdImpression,
  }) async {
    _timer = Timer.periodic(const Duration(seconds: 15), (Timer t) async {
      _timer.cancel();
      await onAdStartAdImpression();
    });
    try {
      AppOpenAd.load(
        adUnitId: PreloadAds.instance.initialData.appOpenId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            AdStats.instance.openAppLoad.value++;
            _timer.cancel();
            AppLogger.log('$ad loaded');
            _appOpenLoadTime = DateTime.now();
            _appOpenAd = ad;
            showAdIfAvailable(onAdStartAdImpression);
          },
          onAdFailedToLoad: (error) async {
            AdStats.instance.openAppFailed.value++;
            await onAdStartAdImpression();
            AppLogger.error('AppOpenAd failed to load: $error');
          },
        ),
      );
    } on PlatformException {
      _timer.cancel();
      await onAdStartAdImpression();
    } catch (error) {
      _timer.cancel();
      await onAdStartAdImpression();
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
  void showAdIfAvailable(Function() onAdStartAdImpression) {
    if (!isAdAvailable) {
      AppLogger.log('Tried to show ad before available.');
      loadAndShowSplashAd(onAdStartAdImpression: onAdStartAdImpression);
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
      loadAndShowSplashAd(onAdStartAdImpression: onAdStartAdImpression);
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
      onAdDismissedFullScreenContent: (ad) async {
        AppLogger.log('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        await onAdStartAdImpression();
      },
    );
    _appOpenAd!.show();
  }
}
